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

    currencies_list = Map.values(currencies)
    initial_active_symbol = currencies_list |> List.first() |> Map.get(:daily_trends_symbol)

    {:ok, {^initial_active_symbol, chart_data}} =
      TimeseriesCache.get_encoded(initial_active_symbol)

    socket =
      socket
      |> assign(:active_index, 0)
      |> assign(:active_symbol, initial_active_symbol)
      |> assign(:active_security, Map.get(currencies, initial_active_symbol))
      |> assign(:timeseries_data, chart_data)
      |> assign(:currencies, currencies_list)
      |> assign(:meta, %Flop.Meta{})
      |> assign(:page_title, "Trendflares currencies performance")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-col">
        <div class="px-4 py-2 bg-neutral-800 flex flex-row items-center justify-between w-full">
          <div class="flex flex-row items-center gap-4 text-white">
            <h1 class="text-lg font-bold"><%= @active_security.name %></h1>
            <p :if={@active_security.sector != ""} class="px-2 py-1 bg-blue-100 rounded-sm">
              <%= @active_security.sector %>
            </p>
            <p :if={@active_security.industry != ""} class="px-2 py-1 bg-blue-100 rounded-sm">
              <%= @active_security.industry %>
            </p>
          </div>
          <div class="flex flex-row items-end gap-2 ml-2">
            <h2 class={["text-white"]}><%= Intl.format_money_decimal(@active_security.price) %></h2>
            <h2 class={[class_for_value(@active_security.change_price)]}>
              <%= Intl.format_money_decimal(@active_security.change_price) %>
            </h2>
            <h2 class={[class_for_value(@active_security.change_percent)]}>
              <%= Intl.format_percent(@active_security.change_percent) %>
            </h2>
            <h2 class="text-white text-xs font-light mb-1">
              Updated <%= Intl.format_datetime_est(
                @active_security.securities_with_performance_updated_at
              ) %>
            </h2>
          </div>
        </div>
        <div class="flex flex-row">
          <div class="flex flex-col w-[35%]" phx-window-keyup="set_active_index">
            <Flop.Phoenix.table
              items={@currencies}
              meta={@meta}
              opts={[
                container: true,
                container_attrs: [class: "w-full screener-table-container lg:h-[75vh]"],
                table_attrs: [class: "min-w-full border-separate", style: "border-spacing: 0"],
                tbody_attrs: [class: "bg-white [&>*:nth-child(#{@active_index + 1})]:bg-blue-100"],
                tbody_td_attrs: [class: "px-2 py-1.5 border-b border-neutral-200 text-xs text-right"],
                tbody_tr_attrs: [class: "hover:bg-neutral-50"],
                thead_th_attrs: [
                  class:
                    "bg-neutral-100 sticky top-0 px-2 py-2 text-left text-xs font-medium text-right"
                ]
              ]}
              path={~p"/currencies"}
            >
              <:col
                :let={item}
                col_style="min-width:50px;"
                label="Ticker"
                field={:daily_trends_symbol}
              >
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
              <:col :let={item} col_style="min-width:50px;" label="$" field={:price}>
                <%= Intl.format_money_decimal(item.price) %>
              </:col>
              <:col :let={item} col_style="min-width:50px;" label="Δ($)" field={:change_price}>
                <span class={class_for_value(item.change_price)}>
                  <%= Intl.format_money_decimal(item.change_price) %>
                </span>
              </:col>
              <:col :let={item} col_style="min-width:50px;" label="Δ(%)" field={:change_percent}>
                <span class={class_for_value(item.change_percent)}>
                  <%= Intl.format_percent(item.change_percent) %>
                </span>
              </:col>
              <:col :let={item} col_style="min-width:50px;" label="5D" field={:day_5_performance}>
                <span class={class_for_value(item.day_5_performance)}>
                  <%= Intl.format_percent(item.day_5_performance) %>
                </span>
              </:col>
              <:col :let={item} col_style="min-width:50px;" label="1M" field={:day_5_performance}>
                <span class={class_for_value(item.month_1_performance)}>
                  <%= Intl.format_percent(item.month_1_performance) %>
                </span>
              </:col>
              <:col :let={item} col_style="min-width:50px;" label="3M" field={:day_5_performance}>
                <span class={class_for_value(item.month_3_performance)}>
                  <%= Intl.format_percent(item.month_3_performance) %>
                </span>
              </:col>
              <:col :let={item} col_style="min-width:50px;" label="6M" field={:day_5_performance}>
                <span class={class_for_value(item.month_6_performance)}>
                  <%= Intl.format_percent(item.month_6_performance) %>
                </span>
              </:col>
              <:col :let={item} col_style="min-width:50px;" label="YTD" field={:day_5_performance}>
                <span class={class_for_value(item.ytd_performance)}>
                  <%= Intl.format_percent(item.ytd_performance) %>
                </span>
              </:col>
              <:col :let={item} col_style="min-width:40px;" label="Trend" field={:trend}>
                <.trend_badge trend={item.trend} />
              </:col>
            </Flop.Phoenix.table>
          </div>
          <div class="flex flex-col w-full">
            <div
              class="h-[40vh] lg:h-[100%] w-full relative"
              data-timeseries={@timeseries_data}
              id="timeseries_chart"
              phx-hook="TimeseriesChart"
              phx-update="ignore"
            >
            </div>
          </div>
        </div>
      </div>
    </div>
    <LoinWeb.FooterComponents.footer />
    """
  end

  @doc """
  Handles key-up-down events.
  """
  @impl true
  def handle_event(
        "set_active_index",
        %{"key" => key_pressed},
        %{assigns: %{active_index: active_index, currencies: currencies}} = socket
      ) do
    max_index = Enum.count(currencies) - 1

    next_active_index =
      case key_pressed do
        "ArrowDown" -> min(active_index + 1, max_index)
        "ArrowUp" -> max(active_index - 1, 0)
        _ -> active_index
      end

    next_active_security = Enum.at(currencies, next_active_index)
    next_active_symbol = Map.get(next_active_security, :daily_trends_symbol)

    {:ok, {^next_active_symbol, chart_data}} = TimeseriesCache.get_encoded(next_active_symbol)

    socket =
      socket
      |> assign(:active_index, next_active_index)
      |> assign(:active_symbol, next_active_symbol)
      |> assign(:active_security, next_active_security)
      |> assign(:timeseries_data, chart_data)

    {:noreply, socket}
  end

  @doc """
  Updates filter.
  """
  @impl Phoenix.LiveView
  def handle_params(params, _, socket) do
    case FMP.filter_performance_screener(@currency_etfs, params) do
      {:ok, {results, meta}} ->
        active_security = List.first(results)
        active_symbol = Map.get(active_security, :daily_trends_symbol)
        {:ok, {^active_symbol, chart_data}} = TimeseriesCache.get_encoded(active_symbol)

        socket =
          socket
          |> assign(:active_index, 0)
          |> assign(:active_symbol, active_symbol)
          |> assign(:active_security, active_security)
          |> assign(:timeseries_data, chart_data)
          |> assign(:currencies, results)
          |> assign(:meta, meta)

        {:noreply, socket}

      _ ->
        {:noreply, push_navigate(socket, to: ~p"/currencies")}
    end
  end

  ####################
  # Private
  ####################

  defp class_for_value(value) do
    case value do
      x when x > 0 -> "text-green-600"
      x when x < 0 -> "text-red-600"
      _ -> "text-neutral-500"
    end
  end

  defp trend_badge(%{trend: nil} = assigns) do
    ~H"""

    """
  end

  defp trend_badge(%{trend: "up"} = assigns) do
    ~H"""
    <Heroicons.arrow_trending_up class="text-green-500 h-6" />
    """
  end

  defp trend_badge(%{trend: "down"} = assigns) do
    ~H"""
    <Heroicons.arrow_trending_down class="text-red-500 h-6" />
    """
  end

  defp trend_badge(%{trend: "neutral"} = assigns) do
    ~H"""
    <Heroicons.minus class="text-neutral-400 h-6" />
    """
  end
end
