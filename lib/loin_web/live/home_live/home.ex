defmodule LoinWeb.HomeLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, TimeseriesCache}

  @impl true
  def mount(_params, _session, socket) do
    with {:ok, chart_data} <- fetch_chart_data(),
         {:ok, sector_trends} <- fetch_sector_trends(),
         sector_trends_updated_at <- get_sector_trends_updated_at(sector_trends) do
      socket =
        socket
        |> assign(:chart_data, chart_data)
        |> assign(:sector_trends, sector_trends)
        |> assign(:sector_trends_updated_at, sector_trends_updated_at)

      {:ok, socket, temporary_assigns: [chart_data: %{}, sector_trends: []]}
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
          <ul class="grid grid-cols-1 gap-1 max-h-96 overflow-scroll">
            <%= for _item <- 1..500 do %>
              <li class="p-2 bg-white hover:bg-gray-50 border border-gray-200 rounded-md">
                <div class="flex flex-row items-center justify-between">
                  <div class="flex flex-row items-center space-x-2">
                    <img
                      alt="Apple Logo"
                      src="https://media.idownloadblog.com/wp-content/uploads/2018/07/Apple-logo-black-and-white.png"
                      class="h-6 w-6 shadow-lg"
                    />
                    <div class="ml-2 flex flex-col">
                      <div class="flex flex-row space-x-2" style="font-size:11px;">
                        <p class="text-gray-500">NYSE:AAPL</p>
                        <p class="font-medium">$128.91</p>
                        <p class="text-green-500">2.29%</p>
                        <p class="text-gray-500">$3.80</p>
                      </div>
                      <p class="font-bold">Apple, Inc.</p>
                      <div class="flex flex-row space-x-2 mt-1" style="font-size:10px;">
                        <p class="px-2 py-1 bg-gray-100 rounded-md">Technology</p>
                        <p class="px-2 py-1 bg-gray-100 rounded-md">Computer Hardware</p>
                      </div>
                    </div>
                  </div>
                  <div class="px-2 py-1 text-xs bg-green-500 rounded-md shadow-lg text-white font-semibold">
                    UPTREND
                  </div>
                  <Heroicons.arrow_trending_up outline class="h-4 w-4 stroke-green-500" />
                  <Heroicons.star outline class="h-6 w-6 stroke-gray-400" />
                </div>
              </li>
            <% end %>
          </ul>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic title="Downtrends">
          <ul class="grid grid-cols-1 gap-1 max-h-96 overflow-scroll">
            <%= for _item <- 1..30 do %>
              <li class="p-2 bg-white hover:bg-gray-50 border border-gray-200 rounded-md">
                <div class="flex flex-row items-center justify-between">
                  <div class="flex flex-row items-center space-x-2">
                    <img
                      alt="Apple Logo"
                      src="https://media.idownloadblog.com/wp-content/uploads/2018/07/Apple-logo-black-and-white.png"
                      class="h-6 w-6 shadow-lg"
                    />
                    <div class="ml-2 flex flex-col">
                      <div class="flex flex-row space-x-2" style="font-size:11px;">
                        <p class="text-gray-500">NYSE:AAPL</p>
                        <p class="font-medium">$128.91</p>
                        <p class="text-green-500">2.29%</p>
                        <p class="text-gray-500">$3.80</p>
                      </div>
                      <p class="font-bold">Apple, Inc.</p>
                      <div class="flex flex-row space-x-2 mt-1" style="font-size:10px;">
                        <p class="px-2 py-1 bg-gray-100 rounded-md">Technology</p>
                        <p class="px-2 py-1 bg-gray-100 rounded-md">Computer Hardware</p>
                      </div>
                    </div>
                  </div>
                  <div class="px-2 py-1 text-xs bg-green-500 rounded-md shadow-lg text-white font-semibold">
                    UPTREND
                  </div>
                  <Heroicons.arrow_trending_up outline class="h-4 w-4 stroke-green-500" />
                  <Heroicons.star outline class="h-6 w-6 stroke-gray-400" />
                </div>
              </li>
            <% end %>
          </ul>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic title="Trend changes">
          <ul class="grid grid-cols-1 gap-1 max-h-96 overflow-scroll">
            <%= for _item <- 1..100 do %>
              <li class="p-2 bg-white hover:bg-gray-50 border border-gray-200 rounded-md">
                <div class="flex flex-row items-center justify-between">
                  <div class="flex flex-row items-center space-x-2">
                    <img
                      alt="Apple Logo"
                      src="https://media.idownloadblog.com/wp-content/uploads/2018/07/Apple-logo-black-and-white.png"
                      class="h-6 w-6 shadow-lg"
                    />
                    <div class="ml-2 flex flex-col">
                      <div class="flex flex-row space-x-2" style="font-size:11px;">
                        <p class="text-gray-500">NYSE:AAPL</p>
                        <p class="font-medium">$128.91</p>
                        <p class="text-green-500">2.29%</p>
                        <p class="text-gray-500">$3.80</p>
                      </div>
                      <p class="font-bold">Apple, Inc.</p>
                      <div class="flex flex-row space-x-2 mt-1" style="font-size:10px;">
                        <p class="px-2 py-1 bg-gray-100 rounded-md">Technology</p>
                        <p class="px-2 py-1 bg-gray-100 rounded-md">Computer Hardware</p>
                      </div>
                    </div>
                  </div>
                  <div class="px-2 py-1 text-xs bg-green-500 rounded-md shadow-lg text-white font-semibold">
                    UPTREND
                  </div>
                  <Heroicons.arrow_trending_up outline class="h-4 w-4 stroke-green-500" />
                  <Heroicons.star outline class="h-6 w-6 stroke-gray-400" />
                </div>
              </li>
            <% end %>
          </ul>
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

  defp fetch_sector_trends() do
    FMP.get_daily_sector_trends()
  end

  defp get_sector_trends_updated_at([]), do: DateTime.utc_now()

  defp get_sector_trends_updated_at(sector_trends) when is_list(sector_trends) do
    sector_trends
    |> Enum.min_by(&Map.get(&1, :updated_at))
    |> Map.get(:updated_at)
    |> Timex.format!("{WDshort} {Mshort} {D}, {YYYY} {h12}:{m}:{s} {AM} {Zabbr}")
  end
end
