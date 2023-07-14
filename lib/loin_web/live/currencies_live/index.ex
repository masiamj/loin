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
    socket = assign(socket, :page_title, "Trendflares currencies performance")
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-col">
        <div class="px-4 py-2 bg-neutral-800 flex flex-row items-center justify-between w-full">
          <div class="flex flex-row items-center gap-4 text-white">
            <h1 class="text-xs lg:text-lg font-bold"><%= @active_security.name %></h1>
            <p :if={@active_security.sector != ""} class="px-2 py-1 bg-blue-100 rounded-sm">
              <%= @active_security.sector %>
            </p>
            <p :if={@active_security.industry != ""} class="px-2 py-1 bg-blue-100 rounded-sm">
              <%= @active_security.industry %>
            </p>
          </div>
          <div class="flex flex-row items-end gap-2 ml-2">
            <h2 class={["text-white text-xs lg:text-base"]}>
              <%= Intl.format_money_decimal(@active_security.price) %>
            </h2>
            <h2 class={[class_for_value(@active_security.change_price), "text-xs lg:text-base"]}>
              <%= Intl.format_money_decimal(@active_security.change_price) %>
            </h2>
            <h2 class={[class_for_value(@active_security.change_percent), "text-xs lg:text-base"]}>
              <%= Intl.format_percent(@active_security.change_percent) %>
            </h2>
            <h2 class="text-white text-xs font-light mb-1 hidden lg:flex">
              Updated <%= Intl.format_datetime_est(
                @active_security.securities_with_performance_updated_at
              ) %>
            </h2>
          </div>
        </div>
        <div class="flex flex-col-reverse lg:flex-row">
          <div class="flex flex-col w-full lg:w-[40%]" phx-window-keyup="set_active_index">
            <Flop.Phoenix.table
              items={@currencies}
              meta={@meta}
              opts={[
                container: true,
                container_attrs: [class: "w-full screener-table-container lg:h-[75vh]"],
                table_attrs: [
                  class: "min-w-full border-separate bg-white",
                  style: "border-spacing: 0"
                ],
                tbody_attrs: [class: "bg-white"],
                tbody_td_attrs: [class: "px-2 py-1.5 border-b border-neutral-200 text-xs text-right"],
                tbody_tr_attrs: &generate_tr_attrs(&1, @active_symbol),
                thead_attrs: [
                  class: "sticky top-0"
                ],
                thead_th_attrs: [
                  class:
                    "bg-neutral-100 sticky top-0 px-2 py-2 text-left text-xs font-medium text-right"
                ]
              ]}
              path={~p"/currencies"}
              row_click={&on_row_click/1}
            >
              <:col
                :let={item}
                attrs={column_attrs()}
                col_style="min-width:50px;"
                label="Ticker"
                field={:daily_trends_symbol}
              >
                <div class={[
                  "flex flex-col py-0.5 -ml-4 pl-4",
                  generate_selected_background(item.daily_trends_symbol, @active_symbol)
                ]}>
                  <span class="font-medium line-clamp-1"><%= item.daily_trends_symbol %></span>
                </div>
              </:col>
              <:col
                :let={item}
                attrs={column_attrs()}
                col_style="min-width:50px;"
                label="$"
                field={:price}
              >
                <%= Intl.format_money_decimal(item.price) %>
              </:col>
              <:col
                :let={item}
                attrs={column_attrs()}
                col_style="min-width:50px;"
                label="Δ($)"
                field={:change_price}
              >
                <span class={class_for_value(item.change_price)}>
                  <%= Intl.format_money_decimal(item.change_price) %>
                </span>
              </:col>
              <:col
                :let={item}
                attrs={column_attrs()}
                col_style="min-width:50px;"
                label="Δ(%)"
                field={:change_percent}
              >
                <span class={class_for_value(item.change_percent)}>
                  <%= Intl.format_percent(item.change_percent) %>
                </span>
              </:col>
              <:col
                :let={item}
                attrs={column_attrs()}
                col_style="min-width:50px;"
                label="5D"
                field={:day_5_performance}
              >
                <span class={class_for_value(item.day_5_performance)}>
                  <%= Intl.format_percent(item.day_5_performance) %>
                </span>
              </:col>
              <:col
                :let={item}
                attrs={column_attrs()}
                col_style="min-width:50px;"
                label="1M"
                field={:month_1_performance}
              >
                <span class={class_for_value(item.month_1_performance)}>
                  <%= Intl.format_percent(item.month_1_performance) %>
                </span>
              </:col>
              <:col
                :let={item}
                attrs={column_attrs()}
                col_style="min-width:50px;"
                label="3M"
                field={:month_3_performance}
              >
                <span class={class_for_value(item.month_3_performance)}>
                  <%= Intl.format_percent(item.month_3_performance) %>
                </span>
              </:col>
              <:col
                :let={item}
                attrs={column_attrs()}
                col_style="min-width:50px;"
                label="6M"
                field={:month_6_performance}
              >
                <span class={class_for_value(item.month_6_performance)}>
                  <%= Intl.format_percent(item.month_6_performance) %>
                </span>
              </:col>
              <:col
                :let={item}
                attrs={column_attrs()}
                col_style="min-width:50px;"
                label="YTD"
                field={:ytd_performance}
              >
                <span class={class_for_value(item.ytd_performance)}>
                  <%= Intl.format_percent(item.ytd_performance) %>
                </span>
              </:col>
              <:col
                :let={item}
                attrs={column_attrs()}
                col_style="min-width:60px;"
                label="Trend"
                field={:trend}
              >
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
    <script>
          window.addEventListener("keydown", function(e) {
          if(["Space","ArrowUp","ArrowDown","ArrowLeft","ArrowRight"].indexOf(e.code) > -1) {
              e.preventDefault();
          }
      }, false);
    </script>
    """
  end

  @doc """
  Handles key-up-down events.
  """
  @impl true
  def handle_event(
        "set_active_index",
        %{"key" => key_pressed},
        %{assigns: %{active_index: active_index, currencies: currencies, max_index: max_index}} =
          socket
      ) do
    next_active_index = determine_next_active_index({active_index, max_index, key_pressed})

    next_active_security = Enum.at(currencies, next_active_index)
    next_active_symbol = Map.get(next_active_security, :daily_trends_symbol)

    {:ok, {^next_active_symbol, chart_data}} = TimeseriesCache.get_encoded(next_active_symbol)

    socket =
      socket
      |> assign(:active_index, next_active_index)
      |> assign(:active_symbol, next_active_symbol)
      |> assign(:active_security, next_active_security)
      |> assign(:timeseries_data, chart_data)

    JS.push_focus(to: "#table-row-#{next_active_symbol}")

    {:noreply, socket}
  end

  @doc """
  Handles key-up-down events.
  """
  @impl true
  def handle_event(
        "set_active_symbol",
        %{"next_active_symbol" => next_active_symbol},
        %{assigns: %{currencies: currencies}} = socket
      ) do
    next_active_index =
      currencies
      |> Enum.find_index(fn %{daily_trends_symbol: daily_trends_symbol} ->
        daily_trends_symbol == next_active_symbol
      end)

    next_active_security = Enum.at(currencies, next_active_index)

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
          |> assign(:active_security, active_security)
          |> assign(:active_symbol, active_symbol)
          |> assign(:max_index, Enum.count(results) - 1)
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

  defp column_attrs() do
    [class: "bg-white px-2 py-1.5 border-b border-neutral-200 text-xs text-right bg-pink-500"]
  end

  defp determine_next_active_index({active_index, max_index, key_pressed}) do
    case key_pressed do
      "ArrowDown" -> min(active_index + 1, max_index)
      "ArrowUp" -> max(active_index - 1, 0)
      _ -> active_index
    end
  end

  defp generate_selected_background(item_symbol, active_symbol) do
    case item_symbol == active_symbol do
      true -> "bg-blue-100"
      false -> "bg-white"
    end
  end

  defp generate_tr_attrs(item, active_symbol) do
    background_class =
      case item.daily_trends_symbol == active_symbol do
        true -> "bg-blue-100"
        false -> "bg-white"
      end

    [
      class: [
        "px-2 py-1.5 border-b border-neutral-200 text-xs text-right cursor-pointer",
        background_class
      ],
      id: "table-row-#{item.daily_trends_symbol}"
    ]
  end

  defp on_row_click(item) do
    JS.push("set_active_symbol", value: %{next_active_symbol: item.daily_trends_symbol})
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
