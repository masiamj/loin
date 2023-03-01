defmodule LoinWeb.SecurityV2Live do
  use LoinWeb, :live_view

  alias Loin.{
    Accounts,
    ETFConstituentsCache,
    ETFSectorWeightCache,
    FMP,
    PeersCache,
    StockETFExposureCache,
    TimeseriesCache
  }

  @impl true
  def mount(%{"symbol" => symbol}, _session, %{assigns: %{current_identity: identity}} = socket) do
    # Right-cases symbol from params
    proper_symbol = String.upcase(symbol)

    # Fetches the original security
    {:ok, %{^proper_symbol => security}} = FMP.get_securities_by_symbols([proper_symbol])

    # Fetches the timeseries chart data
    {:ok, {^proper_symbol, chart_data}} = TimeseriesCache.get_encoded(proper_symbol)

    # Fetches the item in the user's watchlist if available
    {:ok, identity_security} =
      Accounts.get_identity_security_by_identity_and_symbol(identity, proper_symbol)

    # Fetches ETF or Common stock-specific information
    extra_information = fetch_more_relevant_information(security)

    # Extracts real-time symbols to track
    realtime_symbols = extract_realtime_symbols(proper_symbol, extra_information)

    # Assigns values to socket
    socket =
      socket
      |> assign(:is_in_watchlist, is_map(identity_security))
      |> assign(:symbol, proper_symbol)
      |> assign(:original_symbol, proper_symbol)
      |> assign(:security, security)
      |> assign(:timeseries_data, chart_data)
      |> assign(:realtime_symbols, realtime_symbols)
      |> assign(:realtime_updates, %{})
      |> assign(extra_information)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Loin.PubSub, "realtime_quotes")
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="grid grid-cols-1 lg:grid-cols-10 gap-y-4 lg:gap-y-0 divide-x lg:h-[94vh]">
        <div class="grid grid-cols-1 col-span-3 lg:max-h-[94vh]">
          <LoinWeb.Securities.security_quote
            is_in_watchlist={@is_in_watchlist}
            original_symbol={@original_symbol}
            realtime_update={Map.get(@realtime_updates, @symbol, %{})}
            security={@security}
          />
          <div class="lg:overflow-y-scroll">
            <LoinWeb.Securities.quote_section security={@security} />
            <div class="hidden lg:block">
              <%= for %{data: data, title: title} <- @sections do %>
                <p
                  :if={length(data) > 0}
                  class="py-2 px-3 bg-blue-50 text-xs font-medium sticky top-0 text-blue-500"
                >
                  <%= title %> (<%= length(data) %>)
                </p>
                <%= for item <- data do %>
                  <LoinWeb.Securities.security_list_item
                    class="border-b-[1px]"
                    id={item.symbol}
                    item={item}
                    phx-click="select-security"
                    phx-value-symbol={item.symbol}
                    realtime_update={Map.get(@realtime_updates, item.symbol, %{})}
                  />
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
        <div
          class="h-[40vh] lg:h-[94vh] w-full col-span-7"
          data-timeseries={@timeseries_data}
          id="timeseries_chart"
          phx-hook="TimeseriesChart"
          phx-update="ignore"
        >
        </div>
        <div class="block lg:hidden">
          <%= for %{data: data, title: title} <- @sections do %>
            <p
              :if={length(data) > 0}
              class="py-2 px-3 bg-blue-50 text-xs font-medium sticky top-0 text-blue-500"
            >
              <%= title %> (<%= length(data) %>)
            </p>
            <%= for item <- data do %>
              <LoinWeb.Securities.security_list_item
                class="border-b-[1px]"
                id={item.symbol}
                item={item}
                phx-click="select-security"
                phx-value-symbol={item.symbol}
                realtime_update={Map.get(@realtime_updates, item.symbol, %{})}
              />
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event(
        "select-security",
        %{"symbol" => proper_symbol},
        %{assigns: %{current_identity: identity}} = socket
      ) do
    # Fetches the newly selected security
    {:ok, %{^proper_symbol => security}} = FMP.get_securities_by_symbols([proper_symbol])

    # Fetches the timeseries chart data
    {:ok, {^proper_symbol, chart_data}} = TimeseriesCache.get_encoded(proper_symbol)

    # Fetches the item in the user's watchlist if available
    {:ok, identity_security} =
      Accounts.get_identity_security_by_identity_and_symbol(identity, proper_symbol)

    # Assigns values to socket
    socket =
      socket
      |> assign(:is_in_watchlist, is_map(identity_security))
      |> assign(:symbol, proper_symbol)
      |> assign(:security, security)
      |> assign(:timeseries_data, chart_data)

    {:noreply, socket}
  end

  @doc """
  Handles an unauthenticated user wanting to add a stock to their watchlist.
  """
  @impl true
  def handle_event(
        "toggle-identity-security",
        _params,
        %{assigns: %{current_identity: nil}} = socket
      ) do
    {:noreply, push_navigate(socket, to: "/auth")}
  end

  @doc """
  Handles an authenticated user toggling a stock on their watchlist.
  """
  @impl true
  def handle_event("toggle-identity-security", _params, socket) do
    case socket.assigns.is_in_watchlist do
      true ->
        Accounts.delete_identity_security_by_identity_and_symbol(
          socket.assigns.current_identity,
          socket.assigns.symbol
        )

        {:noreply, assign(socket, :is_in_watchlist, false)}

      false ->
        Accounts.create_identity_security(%{
          identity_id: socket.assigns.current_identity.id,
          symbol: socket.assigns.symbol
        })

        {:noreply, assign(socket, :is_in_watchlist, true)}
    end
  end

  @impl true
  def handle_info({:realtime_quote, {symbol, item}}, socket) do
    case MapSet.member?(socket.assigns.realtime_symbols, symbol) do
      true ->
        socket =
          update(socket, :realtime_updates, fn updates -> Map.put(updates, symbol, item) end)

        {:noreply, push_event(socket, "flash-as-new", %{id: symbol})}

      false ->
        {:noreply, socket}
    end
  end

  # Private

  defp extract_realtime_symbols(pertinent_symbol, %{sections: sections} = _extra_information)
       when is_binary(pertinent_symbol) and is_list(sections) do
    sections
    |> Enum.flat_map(&Map.get(&1, :data, %{}))
    |> Enum.map(&Map.get(&1, :symbol))
    |> Enum.concat([pertinent_symbol])
    |> MapSet.new()
  end

  defp fetch_more_relevant_information(%{is_etf: true, symbol: symbol}) do
    {:ok, etf_constituents} = ETFConstituentsCache.get_for_web(symbol)
    {:ok, etf_sector_weights} = ETFSectorWeightCache.get_for_web(symbol)

    %{}
    |> Map.put(:page_title, "#{symbol} ETF 60-day trend, sector exposure, and constituents")
    |> Map.put(:sections, [
      %{title: "Sector weights", data: etf_sector_weights},
      %{title: "ETF Constituents", data: etf_constituents}
    ])
  end

  defp fetch_more_relevant_information(%{is_etf: false, symbol: symbol}) do
    with {:ok, peers} <- PeersCache.get_for_web(symbol),
         {:ok, etf_exposures} <- StockETFExposureCache.get_for_web(symbol) do
      %{
        page_title: "#{symbol} 60-day trend, alternatives, and ETF exposures",
        sections: [
          %{title: "Similar stocks", data: peers},
          %{title: "ETF Exposure", data: etf_exposures}
        ]
      }
    end
  end
end
