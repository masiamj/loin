defmodule LoinWeb.ScreenerLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, Intl}

  @fields [
    name: [label: "Name", op: :ilike_or, placeholder: "Search by name...", type: "search"],
    daily_trends_symbol: [
      label: "Symbol",
      op: :ilike,
      placeholder: "Search by ticker...",
      type: "search"
    ],
    price: [label: "Minimum Price ($)", op: :>=, type: "number"],
    price: [label: "Maximum Price ($)", op: :<=, type: "number"],
    change_percent: [label: "Minimum change today (%)", op: :>=, type: "number"],
    change_percent: [label: "Maximum change today (%)", op: :<=, type: "number"],
    market_cap: [label: "Minimum market cap ($)", op: :>=, type: "number"],
    market_cap: [label: "Maximum market cap ($)", op: :<=, type: "number"],
    trend: [
      label: "Trend",
      options: [{"Uptrend", "up"}, {"Neutral", "neutral"}, {"Downtrend", "down"}],
      prompt: "",
      type: "select"
    ],
    trend_change: [
      label: "Trend change today",
      options: [
        {"Neutral to Uptrend", "neutral_to_up"},
        {"Neutral to Downtrend", "neutral_to_down"},
        {"Uptrend to neutral", "up_to_neutral"},
        {"Uptrend to downtrend", "up_to_down"},
        {"Downtrend to Uptrend", "down_to_up"},
        {"Downtrend to neutral", "down_to_neutral"}
      ],
      prompt: "",
      type: "select"
    ],
    sector: [
      label: "Sector",
      options: [
        {"Communications", "Communication Services"},
        {"Consumer Cyclical", "Consumer Cyclical"},
        {"Consumer Staples", "Consumer Defensive"},
        {"Energy", "Energy"},
        {"Financials", "Financial Services"},
        {"Healthcare", "Healthcare"},
        {"Industrials", "Industrials"},
        {"Materials", "Basic Materials"},
        {"Real Estate", "Real Estate"},
        {"Technology", "Technology"},
        {"Utilities", "Utilities"}
      ],
      prompt: "",
      type: "select"
    ],
    pe: [label: "Minimum PE Ratio ($)", op: :>=, type: "number"],
    pe: [label: "Maximum PE Ratio ($)", op: :<=, type: "number"],
    eps: [label: "Minimum EPS ($)", op: :>=, type: "number"],
    eps: [label: "Maximum EPS ($)", op: :<=, type: "number"],
    pe_ratio_ttm: [label: "Minimum PE Ratio (TTM)", op: :>=, type: "number"],
    pe_ratio_ttm: [label: "Maximum PE Ratio (TTM)", op: :<=, type: "number"],
    peg_ratio_ttm: [label: "Minimum PEG Ratio (TTM)", op: :>=, type: "number"],
    peg_ratio_ttm: [label: "Maximum PEG Ratio (TTM)", op: :<=, type: "number"],
    cash_ratio_ttm: [label: "Minimum Cash Ratio (TTM)", op: :>=, type: "number"],
    cash_ratio_ttm: [label: "Maximum Cash Ratio (TTM)", op: :<=, type: "number"],
    current_ratio_ttm: [label: "Minimum Current Ratio (TTM)", op: :>=, type: "number"],
    current_ratio_ttm: [label: "Maximum Current Ratio (TTM)", op: :<=, type: "number"],
    dividend_yield_ttm: [label: "Minimum Dividend Yield (TTM)", op: :>=, type: "number"],
    dividend_yield_ttm: [label: "Maximum Dividend Yield (TTM)", op: :<=, type: "number"],
    earnings_yield_ttm: [label: "Minimum Earnings Yield (TTM)", op: :>=, type: "number"],
    earnings_yield_ttm: [label: "Maximum Earnings Yield (TTM)", op: :<=, type: "number"],
    price_to_book_ratio_ttm: [
      label: "Minimum Price to Book Ratio (TTM)",
      op: :>=,
      type: "number"
    ],
    price_to_book_ratio_ttm: [
      label: "Maximum Price to Book Ratio (TTM)",
      op: :<=,
      type: "number"
    ],
    price_to_sales_ratio_ttm: [
      label: "Minimum Price to Sales Ratio (TTM)",
      op: :>=,
      type: "number"
    ],
    price_to_sales_ratio_ttm: [
      label: "Maximum Price to Sales Ratio (TTM)",
      op: :>=,
      type: "number"
    ],
    quick_ratio_ttm: [label: "Minimum Quick Ratio (TTM)", op: :>=, type: "number"],
    quick_ratio_ttm: [label: "Maximum Quick Ratio (TTM)", op: :<=, type: "number"],
    return_on_assets_ttm: [
      label: "Minimum Return on Assets (TTM)",
      op: :>=,
      type: "number"
    ],
    return_on_assets_ttm: [
      label: "Maximum Return on Assets (TTM)",
      op: :<=,
      type: "number"
    ],
    return_on_equity_ttm: [
      label: "Minimum Return on Equity (TTM)",
      op: :>=,
      type: "number"
    ],
    return_on_equity_ttm: [
      label: "Maximum Return on Equity (TTM)",
      op: :<=,
      type: "number"
    ]
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:filtered_data, [])
      |> assign(:meta, %{})
      |> assign(:form_fields, @fields)
      |> assign(
        :page_title,
        "TrendFlares stock screener: find your next investment opportunity with real-time trends and analysis"
      )
      |> assign(:realtime_symbols, [])

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Loin.PubSub, "realtime_quotes")
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-row flex-wrap">
        <div class="lg:h-[94vh] w-full lg:w-1/5 lg:overflow-y-scroll">
          <div class="flex flex-row items-center justify-between bg-neutral-50 sticky top-0 p-4">
            <p class="text-neutral-500 text-xs">Screener filters</p>
            <button
              class="text-blue-500 text-xs px-2 py-1 bg-neutral-50 hover:bg-blue-50 rounded"
              phx-click="reset-filter"
            >
              Reset filters
            </button>
          </div>
          <.form
            :let={f}
            class="grid grid-cols-2 lg:grid-cols-1 gap-4 p-4"
            for={@meta}
            phx-change="update-filter"
          >
            <Flop.Phoenix.filter_fields :let={i} form={f} fields={@form_fields}>
              <.input
                id={i.id}
                name={i.name}
                label={i.label}
                type={i.type}
                value={i.value}
                field={{i.form, i.field}}
                {i.rest}
                phx-debounce="250"
              />
            </Flop.Phoenix.filter_fields>
          </.form>
        </div>
        <div class="lg:h-[94vh] w-full lg:w-4/5">
          <Flop.Phoenix.table
            items={@filtered_data}
            meta={@meta}
            opts={[
              container: true,
              container_attrs: [class: "w-full screener-table-container lg:h-[88vh]"],
              table_attrs: [class: "min-w-full border-separate", style: "border-spacing: 0"],
              tbody_td_attrs: [class: "px-2 bg-white border-b border-neutral-200 text-xs"],
              thead_th_attrs: [
                class: "bg-neutral-100 sticky top-0 px-2 py-2 text-left text-xs font-medium"
              ]
            ]}
            path={~p"/screener"}
          >
            <:col :let={item} col_style="min-width:200px;" label="Name" field={:name}>
              <.link navigate={~p"/s/#{item.fmp_securities_symbol}"}>
                <div
                  class="flex flex-col py-0.5 -ml-2 pl-2"
                  data-animate={
                    JS.transition(%JS{}, "animate-flash-as-new",
                      to: "##{item.fmp_securities_symbol}",
                      time: 300
                    )
                  }
                  id={item.fmp_securities_symbol}
                  role="button"
                >
                  <span class="text-neutral-500 line-clamp-1" style="font-size:10px;">
                    <%= item.name %>
                  </span>
                  <span class="font-medium line-clamp-1"><%= item.fmp_securities_symbol %></span>
                </div>
              </.link>
            </:col>
            <:col :let={item} col_style="min-width:100px;" label="Price/share" field={:price}>
              <%= Intl.format_money_decimal(item.price) %>
            </:col>
            <:col :let={item} col_style="min-width:100px;" label="Change" field={:change_value}>
              <span class={class_for_value(item.change_value)}>
                <%= Intl.format_money_decimal(item.change_value) %>
              </span>
            </:col>
            <:col :let={item} col_style="min-width:100px;" label="Change %" field={:change_percent}>
              <span class={class_for_value(item.change_percent)}>
                <%= Intl.format_percent(item.change_percent) %>
              </span>
            </:col>
            <:col :let={item} col_style="min-width:100px;" label="Market cap" field={:market_cap}>
              <%= Intl.format_money_decimal(item.market_cap) %>
            </:col>
            <:col :let={item} col_style="min-width:120px;" label="Trend" field={:trend}>
              <.trend_badge trend={item.trend} />
            </:col>
            <:col :let={item} col_style="min-width:120px;" label="Prev trend" field={:previous_trend}>
              <.trend_badge trend={item.previous_trend} />
            </:col>
            <:col :let={item} col_style="min-width:120px;" label="Trend change" field={:trend_change}>
              <.trend_change_badge trend_change={item.trend_change} />
            </:col>
            <:col :let={item} col_style="min-width:120px;" label="Sector" field={:sector}>
              <%= item.sector %>
            </:col>
            <:col
              :let={item}
              col_style="min-width:100px;"
              label="Employees"
              field={:full_time_employees}
            >
              <%= Intl.format_decimal(item.full_time_employees, :short) %>
            </:col>
            <:col :let={item} col_style="min-width:100px;" label="EPS" field={:eps}>
              <%= Intl.format_money_decimal(item.eps) %>
            </:col>
            <:col
              :let={item}
              col_style="min-width:100px;"
              label="PE Ratio (TTM)"
              field={:pe_ratio_ttm}
            >
              <%= Intl.format_decimal(item.pe_ratio_ttm) %>
            </:col>
            <:col
              :let={item}
              col_style="min-width:100px;"
              label="PEG Ratio (TTM)"
              field={:peg_ratio_ttm}
            >
              <%= Intl.format_decimal(item.peg_ratio_ttm) %>
            </:col>
            <:col
              :let={item}
              col_style="min-width:100px;"
              label="Dividend Yield (TTM)"
              field={:dividend_yield_ttm}
            >
              <%= Intl.format_percent_from_decimal(item.dividend_yield_ttm) %>
            </:col>
            <:col
              :let={item}
              col_style="min-width:100px;"
              label="Earnings Yield (TTM)"
              field={:earnings_yield_ttm}
            >
              <%= Intl.format_percent_from_decimal(item.earnings_yield_ttm) %>
            </:col>
            <:col
              :let={item}
              col_style="min-width:100px;"
              label="Net Profit Margin (TTM)"
              field={:net_profit_margin_ttm}
            >
              <%= Intl.format_percent_from_decimal(item.net_profit_margin_ttm) %>
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
              label="Return on Assets (TTM)"
              field={:return_on_assets_ttm}
            >
              <%= Intl.format_percent_from_decimal(item.return_on_assets_ttm) %>
            </:col>
            <:col
              :let={item}
              col_style="min-width:100px;"
              label="Return on Equity (TTM)"
              field={:return_on_equity_ttm}
            >
              <%= Intl.format_percent_from_decimal(item.return_on_equity_ttm) %>
            </:col>
          </Flop.Phoenix.table>

          <Flop.Phoenix.pagination
            meta={@meta}
            path={~p"/screener"}
            opts={[
              current_link_attrs: [class: "text-white bg-blue-500 p-1 rounded text-xs"],
              next_link_attrs: [
                class:
                  "bg-neutral-50 hover:bg-neutral-100 p-1 rounded text-xs text-neutral-500 hover:text-neutral-800 order-last"
              ],
              next_link_content: "Next",
              page_links: {:ellipsis, 3},
              pagination_link_attrs: [
                class:
                  "bg-neutral-50 hover:bg-neutral-100 p-1 rounded text-xs text-neutral-500 hover:text-neutral-800"
              ],
              pagination_list_attrs: [class: "flex flex-row items-center gap-2"],
              previous_link_attrs: [
                class:
                  "order-first bg-neutral-50 hover:bg-neutral-100 p-1 rounded text-xs text-neutral-500 hover:text-neutral-800"
              ],
              previous_link_content: "Previous",
              wrapper_attrs: [
                class: "flex flex-row items-center gap-2 w-full justify-center min-h-[6vh] py-2"
              ]
            ]}
          />
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    {:noreply, push_patch(socket, to: ~p"/screener?#{params}")}
  end

  @impl true
  def handle_event("reset-filter", _, %{assigns: assigns} = socket) do
    flop = %Flop{} |> Flop.set_page(1) |> Flop.reset_filters()
    path = Flop.Phoenix.build_path(~p"/screener", flop, backend: assigns.meta.backend)
    {:noreply, push_patch(socket, to: path)}
  end

  @impl true
  def handle_info({:realtime_quotes, result_map}, socket) do
    # Extracts the securities that are actually important from the newly published quotes
    pertinent_results = Map.take(result_map, socket.assigns.realtime_symbols)

    new_filtered_data =
      socket.assigns.filtered_data
      |> Enum.map(fn item ->
        Map.merge(item, Map.get(pertinent_results, item.fmp_securities_symbol, %{}))
      end)

    # Updates securities in the main list with their new values
    socket =
      socket
      |> assign(
        :filtered_data,
        new_filtered_data
      )

    {:noreply, push_event(socket, "flash-as-new-many", %{ids: Map.keys(pertinent_results)})}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _, socket) do
    case FMP.filter_screener(params) do
      {:ok, {results, meta}} ->
        socket =
          socket
          |> assign(:filtered_data, results)
          |> assign(:meta, meta)
          |> assign(:realtime_symbols, extract_realtime_symbols(results))

        {:noreply, socket}

      _ ->
        {:noreply, push_navigate(socket, to: ~p"/screener")}
    end
  end

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
