defmodule LoinWeb.HomeLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, TimeseriesCache}

  @impl true
  def mount(_params, _session, socket) do
    with {:ok, chart_data} <- TimeseriesCache.get_many_encoded(["SPY", "QQQ"]),
         {:ok, downtrends} <- FMP.get_securities_via_trend("down", 10),
         {:ok, sector_trends} <- FMP.get_daily_sector_trends(),
         {:ok, trend_changes} <- FMP.get_securities_with_trend_change(10),
         {:ok, uptrends} <- FMP.get_securities_via_trend("up", 10) do
      socket =
        socket
        |> assign(:chart_data, chart_data)
        |> assign(:downtrends, downtrends)
        |> assign(:sector_trends, sector_trends)
        |> assign(:trend_changes, trend_changes)
        |> assign(:uptrends, uptrends)
        |> assign(:page_title, "Stock market trends, sector trends")

      {:ok, socket}
    else
      _result ->
        {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8 lg:py-6">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <LoinWeb.Cards.generic more_link="~p/s/SPY" title="S&P 500 trend">
          <div
            class="h-56 w-full"
            id="sp500_chart"
            data-timeseries={Map.get(@chart_data, "SPY", [])}
            phx-hook="TimeseriesChart"
            phx-update="ignore"
          >
          </div>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic more_link="~p/s/QQQ" title="Nasdaq trend">
          <div
            class="h-56 w-full"
            id="nasdaq_chart"
            data-timeseries={Map.get(@chart_data, "QQQ", [])}
            phx-hook="TimeseriesChart"
            phx-update="ignore"
          >
          </div>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic more_link="~p/screener?type=etf" title="Sector trends">
          <LoinWeb.SectorTrends.heatmap trends={@sector_trends} />
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic more_link="~p/screener?trend=up" title="Uptrends">
          <LoinWeb.Lists.stocks_with_trends data={@uptrends} />
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic more_link="~p/screener?trend=down" title="Downtrends">
          <LoinWeb.Lists.stocks_with_trends data={@downtrends} />
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic more_link="~p/screener?trend_change=all" title="Trend changes">
          <LoinWeb.Lists.stocks_with_trends data={@trend_changes} />
        </LoinWeb.Cards.generic>
      </div>
    </div>
    """
  end
end
