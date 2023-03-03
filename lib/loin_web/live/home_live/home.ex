defmodule LoinWeb.HomeLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, TimeseriesCache}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, chart_securities} = FMP.get_securities_by_symbols(["SPY", "QQQ"])
    {:ok, chart_data} = TimeseriesCache.get_many_encoded(["SPY", "QQQ"])
    {:ok, downtrends} = FMP.get_securities_via_trend("down", 10)
    {:ok, sectors} = FMP.get_sector_etfs()
    {:ok, trend_changes} = FMP.get_securities_with_trend_change(10)
    {:ok, uptrends} = FMP.get_securities_via_trend("up", 10)

    socket =
      socket
      |> assign(:chart_data, chart_data)
      |> assign(:chart_securities, chart_securities)
      |> assign(:downtrends_realtime_symbols, Map.keys(downtrends))
      |> assign(:downtrends, downtrends)
      |> assign(:page_title, "Stock market trends, sector trends")
      |> assign(:qqq_realtime_update, nil)
      |> assign(:sectors, sectors)
      |> assign(:sectors_realtime_symbols, Map.keys(sectors))
      |> assign(:spy_realtime_update, nil)
      |> assign(:trend_changes_realtime_symbols, Map.keys(trend_changes))
      |> assign(:trend_changes, trend_changes)
      |> assign(:uptrends_realtime_symbols, Map.keys(uptrends))
      |> assign(:uptrends, uptrends)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Loin.PubSub, "realtime_quotes")
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8 lg:py-6">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <LoinWeb.Cards.generic more_link={~p"/s/SPY"} title="S&P 500 trend">
          <:title_block>
            <.chart_block security={Map.get(@chart_securities, "SPY")} />
          </:title_block>
          <div
            class="h-56 w-full"
            id="sp500_chart"
            data-hide-legend="true"
            data-timeseries={Map.get(@chart_data, "SPY", [])}
            phx-hook="TimeseriesChart"
            phx-update="ignore"
            data-realtime-update={@spy_realtime_update}
          >
          </div>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic more_link={~p"/s/QQQ"} title="Nasdaq trend">
          <:title_block>
            <.chart_block security={Map.get(@chart_securities, "QQQ")} />
          </:title_block>
          <div
            class="h-56 w-full"
            data-hide-legend="true"
            id="nasdaq_chart"
            data-timeseries={Map.get(@chart_data, "QQQ", [])}
            phx-hook="TimeseriesChart"
            phx-update="ignore"
            data-realtime-update={@qqq_realtime_update}
          >
          </div>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic title="Sector trends">
          <LoinWeb.SectorTrends.heatmap trends={@sectors} />
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic
          more_link={~p"/screener?filters[8][field]=trend&filters[8][value]=up"}
          title="Uptrends"
        >
          <%= for {symbol, item} <- @uptrends do %>
            <LoinWeb.Securities.security_list_item
              class="border-b-[0.25px]"
              href={~p"/s/#{symbol}"}
              id={symbol}
              item={item}
            />
          <% end %>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic
          more_link={~p"/screener?filters[8][field]=trend&filters[8][value]=down"}
          title="Downtrends"
        >
          <ul>
            <%= for {symbol, item} <- @downtrends do %>
              <LoinWeb.Securities.security_list_item
                class="border-b-[0.25px]"
                href={~p"/s/#{symbol}"}
                id={symbol}
                item={item}
              />
            <% end %>
          </ul>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic
          more_link={~p"/screener?filters[9][field]=trend_change&filters[9][value]=neutral_to_up"}
          title="Trend changes"
        >
          <ul>
            <%= for {symbol, item} <- @trend_changes do %>
              <LoinWeb.Securities.security_list_item
                class="border-b-[0.25px]"
                href={~p"/s/#{symbol}"}
                id={symbol}
                item={item}
              />
            <% end %>
          </ul>
        </LoinWeb.Cards.generic>
      </div>
    </div>
    <LoinWeb.FooterComponents.footer />
    """
  end

  @impl true
  def handle_info(:setup_realtime_updates, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Loin.PubSub, "realtime_quotes")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:realtime_quotes, result_map}, socket) do
    # Extracts the securities that are actually important from the newly published quotes
    downtrends_results = Map.take(result_map, socket.assigns.downtrends_realtime_symbols)
    sectors_results = Map.take(result_map, socket.assigns.sectors_realtime_symbols)
    trend_changes_results = Map.take(result_map, socket.assigns.trend_changes_realtime_symbols)
    uptrends_results = Map.take(result_map, socket.assigns.uptrends_realtime_symbols)

    # Collect all IDs to trigger events on
    all_pertinent_results_symbols =
      Enum.concat([
        Map.keys(downtrends_results),
        Map.keys(sectors_results),
        Map.keys(trend_changes_results),
        Map.keys(uptrends_results)
      ])

    # Updates securities with their new values
    socket =
      socket
      |> update(
        :downtrends,
        &Map.merge(&1, downtrends_results, fn _key, existing, new -> Map.merge(existing, new) end)
      )
      |> update(
        :sectors,
        &Map.merge(&1, sectors_results, fn _key, existing, new -> Map.merge(existing, new) end)
      )
      |> update(
        :trend_changes,
        &Map.merge(&1, trend_changes_results, fn _key, existing, new ->
          Map.merge(existing, new)
        end)
      )
      |> update(
        :uptrends,
        &Map.merge(&1, uptrends_results, fn _key, existing, new -> Map.merge(existing, new) end)
      )
      |> assign(get_chart_realtime_updates(result_map, socket))

    {:noreply, push_event(socket, "flash-as-new-many", %{ids: all_pertinent_results_symbols})}
  end

  # Private

  defp get_chart_realtime_updates(result_map, socket) do
    spy_realtime_update =
      case Map.get(result_map, "SPY") do
        nil -> socket.assigns.spy_realtime_update
        result when is_map(result) -> Jason.encode!(result)
      end

    qqq_realtime_update =
      case Map.get(result_map, "QQQ") do
        nil -> socket.assigns.qqq_realtime_update
        result when is_map(result) -> Jason.encode!(result)
      end

    %{spy_realtime_update: spy_realtime_update, qqq_realtime_update: qqq_realtime_update}
  end

  attr :security, :map, required: true

  defp chart_block(assigns) do
    ~H"""
    <div class="flex flex-row overflow-x-scroll items-center gap-3 text-xs">
      <LoinWeb.Securities.security_price value={@security.price} />
      <LoinWeb.Securities.security_change_percent value={@security.change_percent} />
      <LoinWeb.Securities.security_change value={@security.change_value} />
      <LoinWeb.Securities.trend_badge value={@security.trend} />
    </div>
    """
  end
end
