defmodule LoinWeb.HomeLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, TimeseriesCache}

  @impl true
  def mount(_params, _session, socket) do
    with {:ok, chart_data} <- TimeseriesCache.get_many_encoded(["SPY", "QQQ"]),
         {:ok, downtrends} <- FMP.get_securities_via_trend("down", 10),
         {:ok, sectors} <- FMP.get_sector_etfs(),
         {:ok, trend_changes} <- FMP.get_securities_with_trend_change(10),
         {:ok, uptrends} <- FMP.get_securities_via_trend("up", 10),
         realtime_symbols <-
           extract_realtime_symbols([downtrends, sectors, trend_changes, uptrends]) do
      if connected?(socket) do
        subscribe_to_realtime_updates()
      end

      socket =
        socket
        |> assign(:chart_data, chart_data)
        |> assign(:downtrends, downtrends)
        |> assign(:sectors, sectors)
        |> assign(:trend_changes, trend_changes)
        |> assign(:uptrends, uptrends)
        |> assign(:page_title, "Stock market trends, sector trends")
        |> assign(:realtime_symbols, realtime_symbols)
        |> assign(:realtime_updates, %{})

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
        <LoinWeb.Cards.generic more_link={~p"/s/SPY"} title="S&P 500 trend">
          <div
            class="h-56 w-full"
            id="sp500_chart"
            data-timeseries={Map.get(@chart_data, "SPY", [])}
            phx-hook="TimeseriesChart"
            phx-update="ignore"
          >
          </div>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic more_link={~p"/s/QQQ"} title="Nasdaq trend">
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
          <LoinWeb.SectorTrends.heatmap trends={@sectors} />
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic more_link="~p/screener?trend=up" title="Uptrends">
          <%= for {symbol, item} <- @uptrends do %>
            <LoinWeb.Securities.generic_security
              id={symbol}
              item={item}
              realtime_update={Map.get(@realtime_updates, symbol, %{})}
            />
          <% end %>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic more_link="~p/screener?trend=down" title="Downtrends">
          <ul>
            <%= for {symbol, item} <- @downtrends do %>
              <LoinWeb.Securities.generic_security
                id={symbol}
                item={item}
                realtime_update={Map.get(@realtime_updates, symbol, %{})}
              />
            <% end %>
          </ul>
        </LoinWeb.Cards.generic>
        <LoinWeb.Cards.generic more_link="~p/screener?trend_change=all" title="Trend changes">
          <ul>
            <%= for {symbol, item} <- @trend_changes do %>
              <LoinWeb.Securities.generic_security
                id={symbol}
                item={item}
                realtime_update={Map.get(@realtime_updates, symbol, %{})}
              />
            <% end %>
          </ul>
        </LoinWeb.Cards.generic>
      </div>
    </div>
    """
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

  # Private

  defp extract_realtime_symbols(lists) when is_list(lists) do
    lists
    |> Enum.flat_map(&Map.keys/1)
    |> Enum.concat(["SPY", "QQQ"])
    |> MapSet.new()
  end

  defp subscribe_to_realtime_updates() do
    Phoenix.PubSub.subscribe(Loin.PubSub, "realtime_quotes")
  end
end
