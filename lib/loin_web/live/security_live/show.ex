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
  def mount(%{"symbol" => symbol}, _session, socket) do
    mount_data = mount_impl(symbol)
    socket = assign(socket, mount_data)
    {:ok, socket, temporary_assigns: [timeseries_data: []]}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div class="col-span-1 h-[88vh] overflow-y-scroll">
          <div class="space-y-4">
            <LoinWeb.Cards.generic title="Similar stocks">
              <LoinWeb.Lists.similar_stocks data={assigns.peers} />
            </LoinWeb.Cards.generic>
            <%!-- <LoinWeb.Cards.generic title="ETFs with exposure">
              <LoinWeb.Lists.etfs_with_exposures data={assigns.etf_exposures} />
            </LoinWeb.Cards.generic> --%>
          </div>
          <div :if={false} class="space-y-4">
            <LoinWeb.Cards.generic
              :if={length(assigns.etf_sector_weights) > 0}
              title="Sector exposure"
            >
              <LoinWeb.Lists.etf_sector_weights data={assigns.etf_sector_weights} />
            </LoinWeb.Cards.generic>
            <LoinWeb.Cards.generic title="ETF constituents">
              <LoinWeb.Lists.etf_constituents data={assigns.etf_constituents} />
            </LoinWeb.Cards.generic>
          </div>
        </div>
        <div class="col-span-1 lg:col-span-2 h-[82vh]">
          <LoinWeb.Cards.generic title={"#{@symbol} trend"}>
            <div
              class="h-[81vh] w-full"
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

  defp fetch_more_relevant_information(%{is_etf: true, symbol: symbol}) do
    {:ok, etf_constituents} = ETFConstituentsCache.get_for_web(symbol)

    case MapSet.member?(@sector_symbols, symbol) do
      true ->
        %{
          etf_constituents: etf_constituents,
          etf_sector_weights: [],
          page_title: "#{symbol} ETF 60-day trend, sector exposure, and constituents"
        }

      false ->
        {:ok, etf_sector_weights} = ETFSectorWeightCache.get_for_web(symbol)
        %{etf_constituents: etf_constituents, etf_sector_weights: etf_sector_weights}
    end
  end

  defp fetch_more_relevant_information(%{is_etf: false, symbol: symbol}) do
    with {:ok, peers} <- PeersCache.get_for_web(symbol),
         {:ok, etf_exposures} <- StockETFExposureCache.get_for_web(symbol) do
      %{
        etf_exposures: etf_exposures,
        page_title: "#{symbol} 60-day trend, alternatives, and ETF exposures",
        peers: peers
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
