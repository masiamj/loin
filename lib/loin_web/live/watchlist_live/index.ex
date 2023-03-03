defmodule LoinWeb.WatchlistLive do
  use LoinWeb, :live_view

  alias Loin.{
    Accounts,
    TimeseriesCache
  }

  @impl true
  def mount(_params, _session, socket) do
    # Fetches a user's identity securities
    {:ok, securities} =
      Accounts.get_watchlist_securities_by_identity(socket.assigns.current_identity)

    # Create assigns depending on if a user has securities in their watchlist
    case Enum.empty?(securities) do
      true ->
        {:ok, assign(socket, :is_empty, true)}

      false ->
        # Extracts the first (default) security from their watchlist to show
        first_key =
          securities
          |> Map.keys()
          |> List.first()

        security = Map.get(securities, first_key)

        # Fetches the timeseries information for that security
        {:ok, {_, chart_data}} = TimeseriesCache.get_encoded(security.symbol)

        socket =
          socket
          |> assign(:realtime_symbols, Map.keys(securities))
          |> assign(:symbol, security.symbol)
          |> assign(:security, security)
          |> assign(:securities, securities)
          |> assign(:timeseries_data, chart_data)

        if connected?(socket) do
          Phoenix.PubSub.subscribe(Loin.PubSub, "realtime_quotes")
        end

        {:ok, socket}
    end
  end

  @impl true
  def render(%{is_empty: true} = assigns) do
    ~H"""
    <div class="w-full lg:max-w-md mx-auto px-8 lg:px-0 py-16">
      <h1 class="text-3xl font-semibold text-center">Your watchlist is empty</h1>
      <p class="text-center text-gray-500 mt-1">Try adding one of these popular stocks</p>
      <div class="flex flex-row flex-wrap items-center justify-center gap-x-2 gap-y-2 mt-8">
        <%= for symbol <- ["AAPL", "MSFT", "GOOGL", "AMZN", "TSLA", "META", "NVDA", "V", "XOM", "SPY", "VTI", "JPM"] do %>
          <button
            class="bg-white hover:bg-gray-100 border border-gray-300 rounded-md shadow-sm px-2 py-1 text-xs"
            phx-click="add-initial-security"
            phx-value-symbol={symbol}
          >
            <%= symbol %>
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="grid grid-cols-1 lg:grid-cols-10 divide-x lg:h-[94vh]">
        <div class="col-span-3">
          <LoinWeb.Securities.watchlist_security_quote security={@security} />
          <div class="hidden lg:block lg:overflow-y-scroll">
            <p class="py-2 px-3 bg-blue-50 text-xs font-medium sticky top-0 text-blue-500">
              Your watchlist (<%= length(Map.keys(@securities)) %>)
            </p>
            <ul>
              <%= for {symbol, item} <- @securities do %>
                <li class="border-b-[1px]">
                  <LoinWeb.Securities.security_list_item
                    class="border-b-[0.25px]"
                    id={symbol}
                    item={item}
                    phx-click="select-security"
                    phx-value-symbol={symbol}
                  />
                </li>
              <% end %>
            </ul>
          </div>
        </div>
        <div class="col-span-7 relative">
          <div
            class="h-[40vh] lg:h-[94vh] w-full relative"
            data-timeseries={@timeseries_data}
            id="timeseries_chart"
            phx-hook="TimeseriesChart"
            phx-update="ignore"
          >
          </div>
          <div class="absolute top-0 right-0 z-50 text-sm" id="chart-trend-badge">
            <.link href={~p"/screener?filters[8][field]=trend&filters[8][value]=#{@security.trend}"}>
              <LoinWeb.Embeds.Chart.trend_badge value={@security.trend} />
            </.link>
          </div>
        </div>
        <div class="block lg:hidden">
          <p class="py-2 px-3 bg-blue-50 text-xs font-medium sticky top-0 text-blue-500">
            Your watchlist (<%= length(Map.keys(@securities)) %>)
          </p>
          <ul>
            <%= for {symbol, item} <- @securities do %>
              <li class="border-b-[1px]">
                <LoinWeb.Securities.security_list_item
                  class="border-b-[0.25px]"
                  id={symbol}
                  item={item}
                  phx-click="select-security"
                  phx-value-symbol={symbol}
                />
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("add-initial-security", %{"symbol" => symbol}, socket) do
    Loin.Accounts.create_identity_security(%{
      identity_id: socket.assigns.current_identity.id,
      symbol: symbol
    })

    {:noreply, push_navigate(socket, to: "/watchlist")}
  end

  @impl true
  def handle_event("select-security", %{"symbol" => symbol}, socket) do
    security = Map.get(socket.assigns.securities, symbol)
    {:ok, {_, chart_data}} = TimeseriesCache.get_encoded(security.symbol)

    socket =
      socket
      |> assign(:symbol, symbol)
      |> assign(:security, security)
      |> assign(:timeseries_data, chart_data)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:realtime_quotes, result_map}, socket) do
    # Extracts the securities that are actually important from the newly published quotes
    pertinent_results = Map.take(result_map, socket.assigns.realtime_symbols)

    # Updates securities in the main list with their new values
    socket =
      socket
      |> update(
        :securities,
        &Map.merge(&1, pertinent_results, fn _key, existing, new -> Map.merge(existing, new) end)
      )
      |> update(:security, &Map.merge(&1, Map.get(pertinent_results, socket.assigns.symbol, %{})))

    {:noreply, push_event(socket, "flash-as-new-many", %{ids: Map.keys(pertinent_results)})}
  end
end
