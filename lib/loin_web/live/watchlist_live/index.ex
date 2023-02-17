defmodule LoinWeb.WatchlistLive do
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
      <div class="grid grid-cols-1 lg:grid-cols-4 gap-y-4 lg:gap-y-0 divide-x lg:h-[94vh]">
        <div class="grid grid-cols-1 col-span-1 lg:max-h-[94vh]">
          <LoinWeb.Securities.security_quote security={@security} />
          <div class="lg:overflow-y-scroll">
            <LoinWeb.Securities.quote_section security={@security} />
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
                          <LoinWeb.Securities.generic_security item={item} />
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
          class="h-[40vh] lg:h-[94vh] w-full col-span-3"
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
                      <LoinWeb.Securities.generic_security item={item} />
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
    push_navigate(socket, to: "/auth")
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
          identity: socket.assigns.current_identity,
          symbol: socket.assigns.symbol
        })

        {:noreply, assign(socket, :is_in_watchlist, true)}
    end
  end

  @impl true
  def handle_params(%{"symbol" => symbol}, _url, socket) do
    mount_data = mount_impl(symbol, socket.assigns.current_identity)
    {:noreply, assign(socket, mount_data)}
  end

  # Private

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

  defp mount_impl(symbol, identity) do
    proper_symbol = String.upcase(symbol)

    with {:ok, %{^proper_symbol => security}} <- FMP.get_securities_by_symbols([proper_symbol]),
         {:ok, {^proper_symbol, chart_data}} <- TimeseriesCache.get_encoded(proper_symbol),
         is_etf <- Map.get(security, :is_etf),
         {:ok, identity_security} <-
           Accounts.get_identity_security_by_identity_and_symbol(identity, proper_symbol),
         extra_information <- fetch_more_relevant_information(security) do
      %{}
      |> Map.put(:is_etf, is_etf)
      |> Map.put(:is_in_watchlist, is_map(identity_security))
      |> Map.put(:symbol, proper_symbol)
      |> Map.put(:security, security)
      |> Map.put(:timeseries_data, chart_data)
      |> Map.merge(extra_information)
    else
      _ -> %{}
    end
  end
end
