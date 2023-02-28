defmodule LoinWeb.SecurityLive do
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
  def mount(_params, _session, socket) do
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
            realtime_update={Map.get(@realtime_updates, @symbol, %{})}
            security={@security}
          />
          <div class="lg:overflow-y-scroll">
            <LoinWeb.Securities.quote_section
              realtime_update={Map.get(@realtime_updates, @symbol, %{})}
              security={@security}
            />
            <div class="hidden lg:block">
              <ul>
                <%= for %{data: data, title: title} <- @sections do %>
                  <li :if={length(data) > 0}>
                    <p class="py-2 px-3 bg-blue-50 text-xs font-medium sticky top-0 text-blue-500">
                      <%= title %> (<%= length(data) %>)
                    </p>
                    <ul>
                      <%= for item <- data do %>
                        <li class="border-b-[1px]">
                          <LoinWeb.Securities.generic_security
                            id={item.symbol}
                            item={item}
                            realtime_update={Map.get(@realtime_updates, item.symbol, %{})}
                          />
                        </li>
                      <% end %>
                    </ul>
                  </li>
                <% end %>
              </ul>
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
          <ul>
            <%= for %{data: data, title: title} <- @sections do %>
              <li :if={length(data) > 0}>
                <p class="py-2 px-3 bg-blue-50 text-xs font-medium sticky top-0 text-blue-500">
                  <%= title %> (<%= length(data) %>)
                </p>
                <ul>
                  <%= for item <- data do %>
                    <li class="border-b-[1px]">
                      <LoinWeb.Securities.generic_security id={item.symbol} item={item} />
                    </li>
                  <% end %>
                </ul>
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event(
        "toggle-identity-security",
        _params,
        %{assigns: %{current_identity: nil}} = socket
      ) do
    {:noreply, push_navigate(socket, to: "/auth")}
  end

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
  def handle_info(:setup_realtime_updates, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Loin.PubSub, "realtime_quotes")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        {:realtime_quote, {symbol, item}},
        %{assigns: %{realtime_symbols: realtime_symbols}} = socket
      ) do
    case MapSet.member?(realtime_symbols, symbol) do
      true ->
        socket =
          update(socket, :realtime_updates, fn updates -> Map.put(updates, symbol, item) end)

        {:noreply, push_event(socket, "flash-as-new", %{id: symbol})}

      false ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket = load_all_data(params, socket)
    Process.send_after(self(), :setup_realtime_updates, 1000)
    {:noreply, socket}
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

  defp load_all_data(%{"symbol" => symbol}, socket) do
    proper_symbol = String.upcase(symbol)

    with {:ok, %{^proper_symbol => security}} <- FMP.get_securities_by_symbols([proper_symbol]),
         {:ok, {^proper_symbol, chart_data}} <- TimeseriesCache.get_encoded(proper_symbol),
         {:ok, identity_security} <-
           Accounts.get_identity_security_by_identity_and_symbol(
             socket.assigns.current_identity,
             proper_symbol
           ),
         is_etf <- Map.get(security, :is_etf),
         extra_information <- fetch_more_relevant_information(security),
         realtime_symbols <- extract_realtime_symbols(proper_symbol, extra_information) do
      socket =
        socket
        |> assign(:is_etf, is_etf)
        |> assign(:is_in_watchlist, is_map(identity_security))
        |> assign(:symbol, proper_symbol)
        |> assign(:security, security)
        |> assign(:timeseries_data, chart_data)
        |> assign(:realtime_symbols, realtime_symbols)
        |> assign(:realtime_updates, %{})
        |> assign(extra_information)

      socket
    else
      _ ->
        socket
    end
  end
end
