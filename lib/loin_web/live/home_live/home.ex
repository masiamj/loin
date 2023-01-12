defmodule LoinWeb.HomeLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, TimeseriesCache}

  @impl true
  def mount(_params, _session, socket) do
    with {:ok, chart_data} <- fetch_chart_data(),
         {:ok, downtrends} <- fetch_downtrends(),
         {:ok, sector_trends} <- fetch_sector_trends(),
         {:ok, trend_changes} <- fetch_trend_changes(),
         {:ok, uptrends} <- fetch_uptrends(),
         sector_trends_updated_at <- get_sector_trends_updated_at(sector_trends) do
      socket =
        socket
        |> assign(:chart_data, chart_data)
        |> assign(:downtrends, downtrends)
        |> assign(:sector_trends, sector_trends)
        |> assign(:sector_trends_updated_at, sector_trends_updated_at)
        |> assign(:trend_changes, trend_changes)
        |> assign(:uptrends, uptrends)

      {:ok, socket,
       temporary_assigns: [
         chart_data: %{},
         downtrends: [],
         sector_trends: [],
         trend_changes: [],
         uptrends: []
       ]}
    else
      _result -> {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <LoinWeb.Cards.generic title="S&P 500 trend">
          <div
            class="h-64 w-full"
            id="sp500_chart"
            data-timeseries={Map.get(@chart_data, "SPY", [])}
            phx-hook="TimeseriesChart"
            phx-update="ignore"
          >
          </div>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic title="Nasdaq trend">
          <div
            class="h-64 w-full"
            id="nasdaq_chart"
            data-timeseries={Map.get(@chart_data, "QQQ", [])}
            phx-hook="TimeseriesChart"
            phx-update="ignore"
          >
          </div>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic title="Sector trends" updated_at={@sector_trends_updated_at}>
          <LoinWeb.SectorTrends.heatmap trends={@sector_trends} />
        </LoinWeb.Cards.generic>
      </div>
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 mt-8">
        <LoinWeb.Cards.generic title="Uptrends">
          <LoinWeb.Lists.stocks_with_trends class="max-h-96 overflow-scroll" data={@uptrends} />
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic title="Downtrends">
          <LoinWeb.Lists.stocks_with_trends class="max-h-96 overflow-scroll" data={@downtrends} />
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic title="Trend changes">
          <LoinWeb.Lists.stocks_with_trends class="max-h-96 overflow-scroll" data={@trend_changes} />
        </LoinWeb.Cards.generic>
      </div>
    </div>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :home, _params) do
    socket
    |> assign(:page_title, "Home")
  end

  defp fetch_chart_data() do
    {:ok, results} = TimeseriesCache.get_many(["SPY", "QQQ"])
    chart_data = Enum.into(results, %{}, fn {key, value} -> {key, Jason.encode!(value)} end)
    {:ok, chart_data}
  end

  defp fetch_downtrends() do
    FMP.get_securities_via_trend_by_market_cap("down", 50)
  end

  defp fetch_sector_trends() do
    FMP.get_daily_sector_trends()
  end

  defp fetch_trend_changes() do
    FMP.get_securities_with_trend_change_by_market_cap(50)
  end

  defp fetch_uptrends() do
    FMP.get_securities_via_trend_by_market_cap("up", 50)
  end

  defp get_sector_trends_updated_at([]), do: DateTime.utc_now()

  defp get_sector_trends_updated_at(sector_trends) when is_list(sector_trends) do
    sector_trends
    |> Enum.min_by(&Map.get(&1, :updated_at))
    |> Map.get(:updated_at)
    |> Timex.format!("{WDshort} {Mshort} {D}, {YYYY} {h12}:{m}:{s} {AM} {Zabbr}")
  end
end
