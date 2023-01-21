defmodule LoinWeb.SecurityLive do
  use LoinWeb, :live_view

  alias Loin.{
    ETFConstituentsCache,
    ETFSectorWeightCache,
    FMP,
    PeersCache,
    StockETFExposureCache,
    TimeseriesCache
  }

  @sector_symbols MapSet.new([
                    "XLB",
                    "XLC",
                    "XLE",
                    "XLF",
                    "XLI",
                    "XLK",
                    "XLP",
                    "XLRE",
                    "XLU",
                    "XLV",
                    "XLY"
                  ])

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-2 pt-7 pb-6 lg:py-4">
      <div class="flex flex-row-reverse lg:flex-row flex-wrap items-start justify-between w-full">
        <div class="w-full lg:w-1/3 lg:h-[91.5vh] lg:overflow-y-scroll order-last lg:order-first mt-16 lg:mt-0 rounded-md">
          <ul class="grid grid-cols-1 border border-gray-200">
            <%= for %{data: data, title: title} <- @sections do %>
              <li :if={length(data) > 0}>
                <p class="py-3 px-2 bg-blue-100 text-sm text-blue-600 font-medium sticky top-0">
                  <%= title %> (<%= length(data) %>)
                </p>
                <ul>
                  <%= for item <- data do %>
                    <li class="border-b-[1px] border-gray-200">
                      <LoinWeb.Securities.generic_security item={item} />
                    </li>
                  <% end %>
                </ul>
              </li>
            <% end %>
          </ul>
        </div>
        <div class="w-full lg:w-2/3 h-[40vh] lg:h-[86vh] order-first lg:order-first lg:pl-2">
          <LoinWeb.Cards.generic title={"#{@symbol} trend"}>
            <div
              class="h-[40vh] lg:h-[86vh] w-full"
              data-timeseries={@timeseries_data}
              id="timeseries_chart"
              phx-hook="TimeseriesChart"
              phx-update="ignore"
            >
            </div>
          </LoinWeb.Cards.generic>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_params(%{"symbol" => symbol}, _url, socket) do
    mount_data = mount_impl(symbol)
    {:noreply, assign(socket, mount_data)}
  end

  # Private

  defp fetch_more_relevant_information(%{is_etf: true, symbol: symbol}) do
    {:ok, etf_constituents} = ETFConstituentsCache.get_for_web(symbol)

    base = %{
      page_title: "#{symbol} ETF 60-day trend, sector exposure, and constituents"
    }

    case MapSet.member?(@sector_symbols, symbol) do
      true ->
        Map.put(base, :sections, %{
          sections: [
            %{title: "Sector weights", data: []},
            %{title: "ETF Constituents", data: etf_constituents}
          ]
        })

      false ->
        {:ok, etf_sector_weights} = ETFSectorWeightCache.get_for_web(symbol)

        Map.put(base, :sections, [
          %{title: "Sector weights", data: etf_sector_weights},
          %{title: "ETF Constituents", data: etf_constituents}
        ])
    end
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

  defp mount_impl(symbol) do
    proper_symbol = String.upcase(symbol)

    with {:ok, %{^proper_symbol => %{security: security, trend: trend}}} <-
           FMP.get_securities_by_symbols([proper_symbol]),
         {:ok, {^proper_symbol, chart_data}} <- TimeseriesCache.get_encoded(proper_symbol),
         is_etf <- Map.get(security, :is_etf),
         extra_information <- fetch_more_relevant_information(security) do
      %{}
      |> Map.put(:is_etf, is_etf)
      |> Map.put(:symbol, proper_symbol)
      |> Map.put(:security, security)
      |> Map.put(:timeseries_data, chart_data)
      |> Map.put(:trend, trend)
      |> Map.merge(extra_information)
    else
      _ -> %{}
    end
  end
end
