defmodule LoinWeb.ScreenerLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, Intl}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:filtered_data, [])
      |> assign(:meta, %{})

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Flop.Phoenix.table
        items={@filtered_data}
        meta={@meta}
        opts={[
          container: true,
          container_attrs: [class: "w-full screener-table-container lg:h-[88vh]"],
          table_attrs: [class: "min-w-full border-separate", style: "border-spacing: 0"],
          tbody_td_attrs: [class: "px-2 py-0.5 bg-white border-b border-gray-200 text-xs"],
          thead_th_attrs: [class: "bg-gray-100 sticky top-0 px-2 py-2 text-left text-xs font-medium"]
        ]}
        path={~p"/screener"}
      >
        <:col :let={item} col_style="min-width:200px;" label="Name" field={:name}>
          <div class="flex flex-col">
            <span class="text-gray-500" style="font-size:10px;">
              <%= item.fmp_securities_symbol %>
            </span>
            <span class="font-medium line-clamp-1"><%= item.name %></span>
          </div>
        </:col>
        <:col :let={item} col_style="min-width:80px;" label="Close" field={:close}>
          <%= Intl.format_money_decimal(item.close) %>
        </:col>
        <:col :let={item} col_style="min-width:80px;" label="Change" field={:change_value}>
          <span class={class_for_value(item.change_value)}>
            <%= Intl.format_money_decimal(item.change_value) %>
          </span>
        </:col>
        <:col :let={item} col_style="min-width:80px;" label="Change %" field={:change_percent}>
          <span class={class_for_value(item.change_percent)}>
            <%= Intl.format_percent(item.change_percent) %>
          </span>
        </:col>
        <:col :let={item} col_style="min-width:80px;" label="C>200D" field={:close_above_day_200_sma}>
          <%= boolean_content(item.close_above_day_200_sma) %>
        </:col>
        <:col :let={item} col_style="min-width:80px;" label="C>50D" field={:close_above_day_50_sma}>
          <%= boolean_content(item.close_above_day_50_sma) %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="C200D" field={:day_200_sma}>
          <%= Intl.format_money_decimal(item.day_200_sma) %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="C50D" field={:day_50_sma}>
          <%= Intl.format_money_decimal(item.day_50_sma) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:80px;"
          label="C50D>C200D"
          field={:day_50_sma_above_day_200_sma}
        >
          <%= boolean_content(item.day_50_sma_above_day_200_sma) %>
        </:col>
        <:col :let={item} col_style="min-width:120px;" label="Trend" field={:trend}>
          <%= item.trend %>
        </:col>
        <:col :let={item} col_style="min-width:120px;" label="Trend at" field={:daily_trends_date}>
          <%= item.daily_trends_date %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="Prev close" field={:previous_close}>
          <%= Intl.format_money_decimal(item.previous_close) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:80px;"
          label="PC>200D"
          field={:previous_close_above_day_200_sma}
        >
          <%= boolean_content(item.previous_close_above_day_200_sma) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:80px;"
          label="PC>50D"
          field={:previous_close_above_day_50_sma}
        >
          <%= boolean_content(item.previous_close_above_day_50_sma) %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="P200D" field={:previous_day_200_sma}>
          <%= Intl.format_money_decimal(item.previous_day_200_sma) %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="P50D" field={:previous_day_50_sma}>
          <%= Intl.format_money_decimal(item.previous_day_50_sma) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:80px;"
          label="P50D>P200D"
          field={:previous_day_50_sma_above_day_200_sma}
        >
          <%= boolean_content(item.previous_day_50_sma_above_day_200_sma) %>
        </:col>
        <:col :let={item} col_style="min-width:120px;" label="Prev trend" field={:previous_trend}>
          <%= item.previous_trend %>
        </:col>
        <:col :let={item} col_style="min-width:120px;" label="Trend change" field={:trend_change}>
          <%= item.trend_change %>
        </:col>
        <:col :let={item} col_style="min-width:160px;" label="CEO" field={:trend_change}>
          <%= item.ceo %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="EPS" field={:eps}>
          <%= Intl.format_money_decimal(item.eps) %>
        </:col>
        <:col :let={item} col_style="min-width:120px;" label="Exchange" field={:exchange}>
          <%= item.exchange %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="Employees" field={:full_time_employees}>
          <%= Intl.format_decimal(item.full_time_employees) %>
        </:col>
        <:col :let={item} col_style="min-width:120px;" label="Industry" field={:industry}>
          <%= item.industry %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="IPO Date" field={:ipo_date}>
          <%= Intl.format_date(item.ipo_date) %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="Last dividend" field={:last_dividend}>
          <%= Intl.format_money_decimal(item.last_dividend) %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="Market cap" field={:market_cap}>
          <%= Intl.format_money_decimal(item.market_cap) %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="Price" field={:price}>
          <%= Intl.format_money_decimal(item.price) %>
        </:col>
        <:col :let={item} col_style="min-width:120px;" label="Sector" field={:sector}>
          <%= item.sector %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="Website" field={:website}>
          <%= item.website %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="Cash Ratio (TTM)"
          field={:cash_ratio_ttm}
        >
          <%= Intl.format_decimal(item.cash_ratio_ttm) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="Current Ratio (TTM)"
          field={:current_ratio_ttm}
        >
          <%= Intl.format_decimal(item.current_ratio_ttm) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="Dividend Yield (TTM)"
          field={:dividend_yield_ttm}
        >
          <%= Intl.format_percent(item.dividend_yield_ttm) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="Earnings Yield (TTM)"
          field={:earnings_yield_ttm}
        >
          <%= Intl.format_percent(item.earnings_yield_ttm) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="Net Profit Margin (TTM)"
          field={:net_profit_margin_ttm}
        >
          <%= Intl.format_percent(item.net_profit_margin_ttm) %>
        </:col>
        <:col :let={item} col_style="min-width:100px;" label="PE Ratio (TTM)" field={:pe_ratio_ttm}>
          <%= Intl.format_decimal(item.pe_ratio_ttm) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="PE Growth Ratio (TTM)"
          field={:peg_ratio_ttm}
        >
          <%= Intl.format_decimal(item.peg_ratio_ttm) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="Price/Book Ratio (TTM)"
          field={:price_to_book_ratio_ttm}
        >
          <%= Intl.format_decimal(item.price_to_book_ratio_ttm) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="Price/Sales Ratio (TTM)"
          field={:price_to_sales_ratio_ttm}
        >
          <%= Intl.format_decimal(item.price_to_sales_ratio_ttm) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="Quick Ratio (TTM)"
          field={:quick_ratio_ttm}
        >
          <%= Intl.format_decimal(item.quick_ratio_ttm) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="Return on Assets (TTM)"
          field={:return_on_assets_ttm}
        >
          <%= Intl.format_percent(item.return_on_assets_ttm) %>
        </:col>
        <:col
          :let={item}
          col_style="min-width:100px;"
          label="Return on Equity (TTM)"
          field={:return_on_equity_ttm}
        >
          <%= Intl.format_percent(item.return_on_equity_ttm) %>
        </:col>
      </Flop.Phoenix.table>

      <Flop.Phoenix.pagination
        meta={@meta}
        path={~p"/screener"}
        opts={[
          current_link_attrs: [class: "text-white bg-blue-500 p-1 rounded text-xs"],
          next_link_attrs: [
            class:
              "bg-gray-50 hover:bg-gray-100 p-1 rounded text-xs text-gray-500 hover:text-gray-800 order-last"
          ],
          next_link_content: "Next",
          page_links: {:ellipsis, 3},
          pagination_link_attrs: [
            class:
              "bg-gray-50 hover:bg-gray-100 p-1 rounded text-xs text-gray-500 hover:text-gray-800"
          ],
          pagination_list_attrs: [class: "flex flex-row items-center gap-2"],
          previous_link_attrs: [
            class:
              "order-first bg-gray-50 hover:bg-gray-100 p-1 rounded text-xs text-gray-500 hover:text-gray-800"
          ],
          previous_link_content: "Previous",
          wrapper_attrs: [
            class: "flex flex-row items-center gap-2 w-full justify-center min-h-[6vh] py-2"
          ]
        ]}
      />
    </div>
    """
  end

  @impl true
  def handle_event("update-filter", %{"filter" => params}, socket) do
    {:noreply, push_patch(socket, to: ~p"/screener?#{params}")}
  end

  @impl true
  def handle_event("reset-filter", _, %{assigns: assigns} = socket) do
    flop = assigns.meta.flop |> Flop.set_page(1) |> Flop.reset_filters()
    path = Flop.Phoenix.build_path(~p"/screener", flop, backend: assigns.meta.backend)
    {:noreply, push_patch(socket, to: path)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _, socket) do
    case FMP.filter_screener(params) do
      {:ok, {results, meta}} ->
        {:noreply, assign(socket, %{filtered_data: results, meta: meta})}

      _ ->
        {:noreply, push_navigate(socket, to: ~p"/screener")}
    end
  end

  # Private

  defp boolean_content(value) do
    case value do
      true -> "✅"
      false -> "❌"
      _ -> "-"
    end
  end

  defp class_for_value(value) do
    case value do
      x when x > 0 -> "text-green-600"
      x when x < 0 -> "text-red-600"
      _ -> "text-gray-500"
    end
  end
end
