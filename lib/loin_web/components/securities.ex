defmodule LoinWeb.Securities do
  @moduledoc """
  Provides a set of components to display a specific security.
  """
  use LoinWeb, :live_view
  # use Phoenix.Component

  @doc """
  Not sure why we need this, CoreComponents doesn't have it.

  The compiler is complaining and I don't have time to deal with it, so tossing it here.
  """
  def render(assigns) do
    ~H"""
    THIS IS A COMPILER PLACERHOLDER. DO NOT USE ME.
    """
  end

  @doc """
  Renders an ETF constituent.
  """
  attr :item, :map, required: true

  def generic_security(%{item: %{constituent: _constituent}} = assigns) do
    ~H"""
    <.link navigate={~p"/s/#{@item.security.symbol}"}>
      <li class="bg-white hover:bg-gray-100 px-2" role="button">
        <div class="flex flex-row items-center justify-between space-x-2 h-11">
          <div class="flex flex-col w-2/5">
            <div class="flex flex-row items-center gap-1">
              <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                <%= Map.get(@item.security, :name) %>
              </p>
            </div>
            <div class="flex flex-row items-center gap-1">
              <p class="text-xs font-medium"><%= Map.get(@item.security, :symbol) %></p>
              <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                <%= Map.get(@item.constituent, :weight_percentage) %>%
              </p>
            </div>
          </div>
          <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
            <span class="w-1/2">
              <.security_price security={@item.security} />
            </span>
            <span class="w-1/4">
              <.security_change_percent security={@item.security} />
            </span>
            <span class="hidden lg:block w-1/4">
              <.security_change security={@item.security} />
            </span>
          </div>
          <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
            <.trend_badge trend={@item.trend} />
          </div>
        </div>
      </li>
    </.link>
    """
  end

  def generic_security(%{item: %{sector_weight: _sector_weight}} = assigns) do
    ~H"""
    <.link navigate={~p"/s/#{@item.security.symbol}"}>
      <li class="bg-white hover:bg-gray-100 px-2" role="button">
        <div class="flex flex-row items-center justify-between space-x-2 h-11">
          <div class="flex flex-col w-2/5">
            <div class="flex flex-row items-center gap-1">
              <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                <%= Map.get(@item.security, :symbol) %>
              </p>
            </div>
            <div class="flex flex-row items-center gap-1">
              <p class="text-sm font-medium"><%= Map.get(@item.sector_weight, :name) %></p>
              <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                <%= Map.get(@item.sector_weight, :weight_percentage) %>
              </p>
            </div>
          </div>
          <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
            <span class="w-1/2">
              <.security_price security={@item.security} />
            </span>
            <span class="w-1/4">
              <.security_change_percent security={@item.security} />
            </span>
            <span class="hidden lg:block w-1/4">
              <.security_change security={@item.security} />
            </span>
          </div>
          <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
            <.trend_badge trend={@item.trend} />
          </div>
        </div>
      </li>
    </.link>
    """
  end

  def generic_security(%{item: %{exposure: _exposure}} = assigns) do
    ~H"""
    <.link navigate={~p"/s/#{@item.security.symbol}"}>
      <li class="bg-white hover:bg-gray-100 px-2" role="button">
        <div class="flex flex-row items-center justify-between space-x-2 h-11">
          <div class="flex flex-col w-2/5">
            <div class="flex flex-row items-center gap-1">
              <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                <%= Map.get(@item.security, :name) %>
              </p>
            </div>
            <div class="flex flex-row items-center gap-1">
              <p class="text-xs font-medium"><%= Map.get(@item.security, :symbol) %></p>
              <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                (<%= Map.get(@item.exposure, :etf_weight_percentage) %>%)
              </p>
            </div>
          </div>
          <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
            <span class="w-1/2">
              <.security_price security={@item.security} />
            </span>
            <span class="w-1/4">
              <.security_change_percent security={@item.security} />
            </span>
            <span class="hidden lg:block w-1/4">
              <.security_change security={@item.security} />
            </span>
          </div>
          <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
            <.trend_badge trend={@item.trend} />
          </div>
        </div>
      </li>
    </.link>
    """
  end

  def generic_security(assigns) do
    ~H"""
    <.link patch={~p"/s/#{@item.security.symbol}"}>
      <li class="bg-white hover:bg-gray-100 px-2" role="button">
        <div class="flex flex-row items-center justify-between space-x-2 h-11">
          <div class="flex flex-col w-2/5">
            <div class="flex flex-row items-center gap-1">
              <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                <%= Map.get(@item.security, :name) %>
              </p>
            </div>
            <p class="text-xs font-medium"><%= Map.get(@item.security, :symbol) %></p>
          </div>
          <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
            <span class="w-1/2">
              <.security_price security={@item.security} />
            </span>
            <span class="w-1/4">
              <.security_change_percent security={@item.security} />
            </span>
            <span class="hidden lg:block w-1/4">
              <.security_change security={@item.security} />
            </span>
          </div>
          <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
            <.trend_badge trend={@item.trend} />
          </div>
        </div>
      </li>
    </.link>
    """
  end

  @doc """
  Renders a quote section for a specific security.
  """
  attr :security, :map, required: true
  attr :trend, :map, default: %{}
  attr :ttm_ratios, :map, default: %{}

  def quote_section(assigns) do
    ~H"""
    <div class="bg-white pb-3 lg:h-full lg:overflow-y-scroll">
      <div class="flex flex-col sticky top-0 py-2 px-4 bg-blue-50">
        <h1 class="font-semibold text-blue-500"><%= @security.name %> (<%= @security.symbol %>)</h1>
        <div class="flex flex-row overflow-x-scroll items-center gap-2 mt-1 text-sm">
          <.security_price security={@security} />
          <.security_change_percent security={@security} />
          <.security_change security={@security} />
          <.trend_badge trend={@trend} />
          <.sector_badge security={@security} />
          <%!-- <.industry_badge security={@security} /> --%>
        </div>
      </div>
      <div class="px-4 py-2">
        <.read_more content={@security.description} id="quote-security-description" />
        <div class="grid grid-cols-2 gap-x-4 gap-y-2 mt-4">
          <.labeled_data_item
            label="Market cap"
            value={Loin.Intl.format_money_decimal(@security.market_cap)}
          />
          <.labeled_data_item label="CEO" value={@security.ceo} />
          <.labeled_data_item
            label="Full time employees"
            value={Loin.Intl.format_money_decimal(@security.full_time_employees)}
          />
          <.labeled_data_item
            :if={String.length(@security.city) > 0 and String.length(@security.state) > 0}
            label="Headquarters"
            value={"#{@security.city}, #{@security.state}"}
          />
          <.labeled_data_item label="IPO Date" value={Loin.Intl.format_date(@security.ipo_date)} />
          <.labeled_data_item
            label="Last dividend"
            value={Loin.Intl.format_money_decimal(@security.last_dividend)}
          />
          <.labeled_data_item
            label="Price-to-earnings (PE) Ratio"
            value={Loin.Intl.format_decimal(@security.pe)}
          />
          <.labeled_data_item
            label="Earnings-per-share (EPS)"
            value={Loin.Intl.format_money_decimal(@security.eps)}
          />
          <.labeled_data_item
            label="Cash ratio (TTM)"
            value={Map.get(@ttm_ratios, :cash_ratio, nil) |> Loin.Intl.format_decimal()}
          />
          <.labeled_data_item
            label="Current ratio (TTM)"
            value={Map.get(@ttm_ratios, :current_ratio, nil) |> Loin.Intl.format_decimal()}
          />
          <.labeled_data_item
            label="Dividend yield (TTM)"
            value={
              Map.get(@ttm_ratios, :dividend_yield, nil) |> Loin.Intl.format_percent_from_decimal()
            }
          />
          <.labeled_data_item
            label="Earnings yield (TTM)"
            value={
              Map.get(@ttm_ratios, :earnings_yield, nil) |> Loin.Intl.format_percent_from_decimal()
            }
          />
          <.labeled_data_item
            label="Net profit margin (TTM)"
            value={
              Map.get(@ttm_ratios, :net_profit_margin, nil) |> Loin.Intl.format_percent_from_decimal()
            }
          />
          <.labeled_data_item
            label="PE ratio (TTM)"
            value={Map.get(@ttm_ratios, :pe_ratio, nil) |> Loin.Intl.format_decimal()}
          />
          <.labeled_data_item
            label="PEG ratio (TTM)"
            value={Map.get(@ttm_ratios, :peg_ratio, nil) |> Loin.Intl.format_decimal()}
          />
          <.labeled_data_item
            label="Price-to-book ratio (TTM)"
            value={Map.get(@ttm_ratios, :price_to_book_ratio, nil) |> Loin.Intl.format_decimal()}
          />
          <.labeled_data_item
            label="Price-to-sales ratio (TTM)"
            value={Map.get(@ttm_ratios, :price_to_sales_ratio, nil) |> Loin.Intl.format_decimal()}
          />
          <.labeled_data_item
            label="Quick ratio (TTM)"
            value={Map.get(@ttm_ratios, :quick_ratio, nil) |> Loin.Intl.format_decimal()}
          />
          <.labeled_data_item
            label="Return on assets (TTM)"
            value={
              Map.get(@ttm_ratios, :return_on_assets, nil) |> Loin.Intl.format_percent_from_decimal()
            }
          />
          <.labeled_data_item
            label="Return on equity (TTM)"
            value={
              Map.get(@ttm_ratios, :return_on_equity, nil) |> Loin.Intl.format_percent_from_decimal()
            }
          />
        </div>
      </div>
    </div>
    """
  end

  defp class_for_value(value) do
    case value do
      0.0 -> "text-gray-500"
      value when value > 0 -> "text-green-500"
      value when value < 0 -> "text-red-500"
    end
  end

  def industry_badge(assigns) do
    value =
      assigns
      |> Map.get(:security, %{})
      |> Map.get(:industry)

    assigns = assign(assigns, :value, value)

    ~H"""
    <.link
      class="px-2 py-0.5 bg-blue-100 text-blue-500 text-xs rounded font-medium w-min-16 line-clamp-1"
      navigate={~p"/"}
    >
      <%= @value %>
    </.link>
    """
  end

  defp labeled_data_item(assigns) do
    ~H"""
    <div>
      <label class="text-xs text-gray-500"><%= @label %></label>
      <p class="text-sm"><%= @value %></p>
    </div>
    """
  end

  def sector_badge(assigns) do
    value =
      assigns
      |> Map.get(:security, %{})
      |> Map.get(:sector)

    assigns = assign(assigns, :value, value)

    ~H"""
    <.link class="px-2 py-0.5 bg-blue-100 text-blue-500 text-xs rounded font-medium" navigate={~p"/"}>
      <%= @value %>
    </.link>
    """
  end

  def security_price(assigns) do
    ~H"""
    <span class="font-medium text-gray-700">
      <%= Loin.Intl.format_money_decimal(@security.price) %>
    </span>
    """
  end

  def security_change(assigns) do
    with raw_value <- Map.get(assigns.security, :change, 0.0),
         class <- class_for_value(raw_value),
         value <- Loin.Intl.format_money_decimal(raw_value) do
      assigns =
        assigns
        |> assign(:class, class)
        |> assign(:value, value)

      ~H"""
      <span class={@class}>
        <%= @value %>
      </span>
      """
    end
  end

  def security_change_percent(assigns) do
    with raw_value <- Map.get(assigns.security, :change_percent, nil),
         class <- class_for_value(raw_value),
         value <- Loin.Intl.format_percent(raw_value) do
      assigns =
        assigns
        |> assign(:class, class)
        |> assign(:value, value)

      ~H"""
      <span class={@class}>
        <%= @value %>
      </span>
      """
    end
  end

  defp trend_badge(%{trend: nil} = assigns) do
    ~H"""

    """
  end

  defp trend_badge(%{trend: %{trend: "up"}} = assigns) do
    ~H"""
    <div class="text-green-500 text-xs font-medium flex items-center justify-center bg-green-100 px-2 py-0.5 rounded">
      <span>Uptrend</span>
    </div>
    """
  end

  defp trend_badge(%{trend: %{trend: "down"}} = assigns) do
    ~H"""
    <div class="text-red-500 text-xs font-medium flex items-center justify-center bg-red-100 px-2 py-0.5 rounded">
      <span>Downtrend</span>
    </div>
    """
  end

  defp trend_badge(%{trend: %{trend: "neutral"}} = assigns) do
    ~H"""
    <div class="text-gray-500 text-xs font-medium flex items-center justify-center bg-gray-100 px-2 py-0.5 rounded">
      <span>Neutral</span>
    </div>
    """
  end

  defp trend_badge(%{trend: %{trend: nil}} = assigns) do
    ~H"""
    <div></div>
    """
  end
end
