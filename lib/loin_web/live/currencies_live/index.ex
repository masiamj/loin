defmodule LoinWeb.CurrenciesLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, Intl, TimeseriesCache}

  @currency_etfs [
    "DXJ",
    "EWG",
    "EWI",
    "EWJ",
    "EWW",
    "EWT",
    "EWS",
    "EWP",
    "EWQ",
    "EWU",
    "EWC",
    "EWH",
    "TUR",
    "EIDO",
    "ENZL",
    "EPHE",
    "EWA",
    "EWL",
    "EWM",
    "EWO",
    "EWY",
    "EZA",
    "FXI",
    "GXC",
    "MCHI",
    "NORW",
    "EIS",
    "EWZ",
    "PIN",
    "EPOL",
    "EWD",
    "EWK",
    "EWN"
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, currencies} = FMP.get_performance_securities_by_symbols(@currency_etfs)

    socket =
      socket
      |> assign(:currencies, Map.values(currencies))
      |> assign(:meta, %Flop.Meta{})
      |> assign(:page_title, "Trendflares currencies performance")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-col">
        <div class="flex flex-row">
          <div class="flex flex-col w-[30%] bg-green-500">
          <Flop.Phoenix.table
            items={@currencies}
            meta={@meta}
            opts={[
              container: true,
              container_attrs: [class: "w-full screener-table-container lg:h-[80vh]"],
              table_attrs: [class: "min-w-full border-separate", style: "border-spacing: 0"],
              tbody_td_attrs: [class: "px-2 bg-white border-b border-neutral-200 text-xs"],
              thead_th_attrs: [
                class: "bg-neutral-100 sticky top-0 px-2 py-2 text-left text-xs font-medium"
              ]
            ]}
            path={~p"/currencies"}
          >
            <:col :let={item} col_style="min-width:60px;" label="Name" field={:name}>
              <.link navigate={~p"/s/#{item.daily_trends_symbol}"}>
                <div
                  class="flex flex-col py-0.5 -ml-2 pl-2"
                  data-animate={
                    JS.transition(%JS{}, "animate-flash-as-new",
                      to: "##{item.daily_trends_symbol}",
                      time: 300
                    )
                  }
                  id={item.daily_trends_symbol}
                  role="button"
                >
                  <span class="font-medium line-clamp-1"><%= item.daily_trends_symbol %></span>
                </div>
              </.link>
            </:col>
            <:col :let={item} col_style="min-width:60px;" label="$" field={:price}>
              <%= Intl.format_money_decimal(item.price) %>
            </:col>
            <:col :let={item} col_style="min-width:60px;" label="Δ($)" field={:change_price}>
              <span class={class_for_value(item.change_price)}>
                <%= Intl.format_money_decimal(item.change_price) %>
              </span>
            </:col>
            <:col :let={item} col_style="min-width:60px;" label="Δ(%)" field={:change_percent}>
              <span class={class_for_value(item.change_percent)}>
                <%= Intl.format_percent(item.change_percent) %>
              </span>
            </:col>
            <:col :let={item} col_style="min-width:60px;" label="5D" field={:day_5_performance}>
              <span class={class_for_value(item.day_5_performance)}>
                <%= Intl.format_percent(item.day_5_performance) %>
              </span>
            </:col>
            <:col :let={item} col_style="min-width:60px;" label="1M" field={:day_5_performance}>
              <span class={class_for_value(item.month_1_performance)}>
                <%= Intl.format_percent(item.month_1_performance) %>
              </span>
            </:col>
            <:col :let={item} col_style="min-width:60px;" label="3M" field={:day_5_performance}>
              <span class={class_for_value(item.month_3_performance)}>
                <%= Intl.format_percent(item.month_3_performance) %>
              </span>
            </:col>
            <:col :let={item} col_style="min-width:60px;" label="6M" field={:day_5_performance}>
              <span class={class_for_value(item.month_6_performance)}>
                <%= Intl.format_percent(item.month_6_performance) %>
              </span>
            </:col>
            <:col :let={item} col_style="min-width:60px;" label="YTD" field={:day_5_performance}>
              <span class={class_for_value(item.ytd_performance)}>
                <%= Intl.format_percent(item.ytd_performance) %>
              </span>
            </:col>
            <:col :let={item} col_style="min-width:80px;" label="Trend" field={:trend}>
              <.trend_badge trend={item.trend} />
            </:col>
          </Flop.Phoenix.table>
          </div>
          <div class="flex flex-col w-[70%] bg-red-500">
            <h1>Also this</h1>
          </div>
        </div>
      </div>
    </div>
    <LoinWeb.FooterComponents.footer />
    """
  end

  ####################
  # Private
  ####################

  # Private

  defp class_for_value(value) do
    case value do
      x when x > 0 -> "text-green-600"
      x when x < 0 -> "text-red-600"
      _ -> "text-neutral-500"
    end
  end

  defp extract_realtime_symbols(securities) when is_list(securities) do
    Enum.map(securities, &Map.get(&1, :symbol))
  end

  defp trend_badge(%{trend: nil} = assigns) do
    ~H"""

    """
  end

  defp trend_badge(%{trend: "up"} = assigns) do
    ~H"""
    <div class="text-green-500 text-xs font-medium flex items-center justify-center bg-green-100 px-2 py-0.5 rounded">
      <span>Uptrend</span>
    </div>
    """
  end

  defp trend_badge(%{trend: "down"} = assigns) do
    ~H"""
    <div class="text-red-500 text-xs font-medium flex items-center justify-center bg-red-100 px-2 py-0.5 rounded">
      <span>Downtrend</span>
    </div>
    """
  end

  defp trend_badge(%{trend: "neutral"} = assigns) do
    ~H"""
    <div class="text-neutral-500 text-xs font-medium flex items-center justify-center bg-neutral-100 px-2 py-0.5 rounded">
      <span>Neutral</span>
    </div>
    """
  end

  defp trend_change_badge(%{trend_change: nil} = assigns) do
    ~H"""

    """
  end

  defp trend_change_badge(%{trend_change: trend_change} = assigns)
       when trend_change in ["down_to_up", "neutral_to_up"] do
    ~H"""
    <div class="text-green-500 text-xs font-medium flex items-center justify-center bg-green-100 px-2 py-0.5 rounded">
      <span>To Uptrend</span>
    </div>
    """
  end

  defp trend_change_badge(%{trend_change: trend_change} = assigns)
       when trend_change in ["up_to_down", "neutral_to_down"] do
    ~H"""
    <div class="text-red-500 text-xs font-medium flex items-center justify-center bg-red-100 px-2 py-0.5 rounded">
      <span>To Downtrend</span>
    </div>
    """
  end

  defp trend_change_badge(%{trend_change: trend_change} = assigns)
       when trend_change in ["up_to_neutral", "down_to_neutral"] do
    ~H"""
    <div class="text-neutral-500 text-xs font-medium flex items-center justify-center bg-neutral-100 px-2 py-0.5 rounded">
      <span>To Neutral</span>
    </div>
    """
  end
end
