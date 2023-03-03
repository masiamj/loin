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

  attr :class, :string, required: false
  attr :href, :string, required: false
  attr :id, :string, default: ""
  attr :item, :map, required: true
  attr :realtime_update, :map, default: %{}
  attr :watchlist, :boolean, default: false
  attr :rest, :global

  def security_list_item(%{href: _href} = assigns) do
    ~H"""
    <.link class={[@class]} navigate={@href || ~p"/s/#{@item.symbol}"}>
      <.security_list_item_body id={@id} item={@item} realtime_update={@realtime_update} />
    </.link>
    """
  end

  def security_list_item(assigns) do
    ~H"""
    <div class={["cursor-pointer", @class]} {@rest}>
      <.security_list_item_body id={@id} item={@item} realtime_update={@realtime_update} />
    </div>
    """
  end

  attr :constituent, :map, required: false
  attr :exposure, :map, required: false
  attr :label, :string, required: true
  attr :sector_weight, :map, required: false
  attr :symbol, :string, required: true

  def context_specific_label(%{constituent: %{weight_percentage: _}} = assigns) do
    ~H"""
    <div class="flex flex-col w-2/5">
      <div class="flex flex-row items-center gap-1">
        <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
          <%= @label %>
        </p>
      </div>
      <div class="flex flex-row items-center gap-1">
        <p class="text-xs font-medium"><%= @symbol %></p>
        <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
          <%= @constituent.weight_percentage %>%
        </p>
      </div>
    </div>
    """
  end

  def context_specific_label(%{exposure: %{etf_weight_percentage: _}} = assigns) do
    ~H"""
    <div class="flex flex-col w-2/5">
      <div class="flex flex-row items-center gap-1">
        <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
          <%= @label %>
        </p>
      </div>
      <div class="flex flex-row items-center gap-1">
        <p class="text-xs font-medium"><%= @symbol %></p>
        <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
          <%= @exposure.etf_weight_percentage %>%
        </p>
      </div>
    </div>
    """
  end

  def context_specific_label(%{sector_weight: %{weight_percentage: _}} = assigns) do
    ~H"""
    <div class="flex flex-col w-2/5">
      <div class="flex flex-row items-center gap-1">
        <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
          <%= @label %>
        </p>
      </div>
      <div class="flex flex-row items-center gap-1">
        <p class="text-sm font-medium line-clamp-1"><%= @symbol %></p>
        <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
          <%= @sector_weight.weight_percentage %>
        </p>
      </div>
    </div>
    """
  end

  def context_specific_label(assigns) do
    ~H"""
    <div class="flex flex-col w-2/5">
      <div class="flex flex-row items-center gap-1">
        <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
          <%= @label %>
        </p>
      </div>
      <p class="text-xs font-medium"><%= @symbol %></p>
    </div>
    """
  end

  @doc """
  Renders a quote section for a specific security.
  """
  attr :security, :map, required: true

  def quote_section(assigns) do
    ~H"""
    <div class="bg-white pb-3">
      <div class="px-4 py-2">
        <.read_more content={@security.description} id="quote-security-description" />
        <div class="grid grid-cols-2 gap-x-4 gap-y-2 mt-4">
          <.labeled_data_item
            :if={@security.market_cap}
            label="Market cap"
            value={Loin.Intl.format_money_decimal(@security.market_cap)}
          />
          <.labeled_data_item
            :if={@security.ceo && @security.ceo != "None"}
            label="CEO"
            value={@security.ceo}
          />
          <.labeled_data_item
            :if={@security.full_time_employees}
            label="Full time employees"
            value={Loin.Intl.format_decimal(@security.full_time_employees)}
          />
          <.labeled_data_item
            :if={String.length(@security.city) > 0 and String.length(@security.state) > 0}
            label="Headquarters"
            value={"#{@security.city}, #{@security.state}"}
          />
          <.labeled_data_item
            :if={@security.ipo_date}
            label="IPO Date"
            value={Loin.Intl.format_date(@security.ipo_date)}
          />
          <.labeled_data_item
            :if={@security.last_dividend}
            label="Last dividend"
            value={Loin.Intl.format_money_decimal(@security.last_dividend)}
          />
          <.labeled_data_item
            :if={@security.pe}
            label="Price-to-earnings (PE) Ratio"
            value={Loin.Intl.format_decimal(@security.pe)}
          />
          <.labeled_data_item
            :if={@security.eps}
            label="Earnings-per-share (EPS)"
            value={Loin.Intl.format_money_decimal(@security.eps)}
          />
          <.labeled_data_item
            :if={@security.cash_ratio_ttm}
            label="Cash ratio (TTM)"
            value={Loin.Intl.format_decimal(@security.cash_ratio_ttm)}
          />
          <.labeled_data_item
            :if={@security.current_ratio_ttm}
            label="Current ratio (TTM)"
            value={Loin.Intl.format_decimal(@security.current_ratio_ttm)}
          />
          <.labeled_data_item
            :if={@security.dividend_yield_ttm}
            label="Dividend yield (TTM)"
            value={Loin.Intl.format_percent_from_decimal(@security.dividend_yield_ttm)}
          />
          <.labeled_data_item
            :if={@security.earnings_yield_ttm}
            label="Earnings yield (TTM)"
            value={Loin.Intl.format_percent_from_decimal(@security.earnings_yield_ttm)}
          />
          <.labeled_data_item
            :if={@security.net_profit_margin_ttm}
            label="Net profit margin (TTM)"
            value={Loin.Intl.format_percent_from_decimal(@security.net_profit_margin_ttm)}
          />
          <.labeled_data_item
            :if={@security.pe_ratio_ttm}
            label="PE ratio (TTM)"
            value={Loin.Intl.format_decimal(@security.pe_ratio_ttm)}
          />
          <.labeled_data_item
            :if={@security.peg_ratio_ttm}
            label="PEG ratio (TTM)"
            value={Loin.Intl.format_decimal(@security.peg_ratio_ttm)}
          />
          <.labeled_data_item
            :if={@security.price_to_book_ratio_ttm}
            label="Price-to-book ratio (TTM)"
            value={Loin.Intl.format_decimal(@security.price_to_book_ratio_ttm)}
          />
          <.labeled_data_item
            :if={@security.price_to_sales_ratio_ttm}
            label="Price-to-sales ratio (TTM)"
            value={Loin.Intl.format_decimal(@security.price_to_sales_ratio_ttm)}
          />
          <.labeled_data_item
            :if={@security.quick_ratio_ttm}
            label="Quick ratio (TTM)"
            value={Loin.Intl.format_decimal(@security.quick_ratio_ttm)}
          />
          <.labeled_data_item
            :if={@security.return_on_assets_ttm}
            label="Return on assets (TTM)"
            value={Loin.Intl.format_percent_from_decimal(@security.return_on_assets_ttm)}
          />
          <.labeled_data_item
            :if={@security.return_on_equity_ttm}
            label="Return on equity (TTM)"
            value={Loin.Intl.format_percent_from_decimal(@security.return_on_equity_ttm)}
          />
        </div>
      </div>
    </div>
    """
  end

  attr :id, :string, default: ""
  attr :item, :map, required: true
  attr :realtime_update, :map, default: %{}
  attr :watchlist, :boolean, default: false

  def security_list_item_body(assigns) do
    ~H"""
    <div
      class="bg-white hover:bg-gray-100 px-2 border-b border-gray-200"
      data-animate={JS.transition(%JS{}, "animate-flash-as-new", to: "##{@id}", time: 300)}
      id={@id}
    >
      <div class="flex flex-row items-center justify-between space-x-2 h-11">
        <.context_specific_label
          constituent={Map.get(@item, :constituent, nil)}
          exposure={Map.get(@item, :exposure, nil)}
          label={@item.name}
          sector_weight={Map.get(@item, :sector_weight, nil)}
          symbol={@item.symbol}
        />
        <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
          <span class="w-1/2">
            <.security_price value={Map.get(@realtime_update, :price, @item.price)} />
          </span>
          <span class="w-1/4">
            <.security_change_percent value={
              Map.get(@realtime_update, :change_percent, @item.change_percent)
            } />
          </span>
          <span class="hidden lg:block w-1/4">
            <.security_change value={Map.get(@realtime_update, :change_value, @item.change_value)} />
          </span>
        </div>
        <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
          <.trend_badge value={@item.trend} />
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a quote section for a specific security.
  """
  attr :is_in_watchlist, :boolean, required: true
  attr :original_symbol, :string, required: false
  attr :realtime_update, :map, default: %{}
  attr :security, :map, required: true

  def security_quote(assigns) do
    ~H"""
    <div class="flex flex-col sticky top-0 pt-2 pb-3 px-4 border border-b border-gray-200 shadow-sm">
      <div class="flex flex-row items-start justify-between space-x-4">
        <div class="flex flex-col">
          <p
            :if={@original_symbol != @security.symbol}
            class="text-blue-600 px-1 text-xs mb-2 cursor-pointer flex flex-row"
            phx-click="select-security"
            phx-value-symbol={@original_symbol}
          >
            <Heroicons.arrow_left mini class="h-4 w-4 mr-1" /> Back to <%= @original_symbol %>
          </p>
          <div class="flex flex-row items-center gap-2">
            <img
              :if={@security.image}
              src={@security.image}
              class="h-8 w-8 rounded-md object-contain"
            />
            <h1 class="font-semibold"><%= @security.name %> (<%= @security.symbol %>)</h1>
          </div>
        </div>
        <div class="flex flex-row gap-2">
          <button
            :if={!@is_in_watchlist}
            class="bg-white hover:bg-gray-100 border border-gray-300 rounded-md shadow-sm px-2 py-1 text-xs"
            phx-click="toggle-identity-security"
          >
            Follow
          </button>
          <button
            :if={@is_in_watchlist}
            class="bg-rose-700 hover:bg-rose-800 rounded-md shadow-sm px-2 py-1 text-xs text-white"
            phx-click="toggle-identity-security"
          >
            Unfollow
          </button>
          <.link
            :if={@original_symbol != @security.symbol}
            class="bg-white hover:bg-gray-100 border border-gray-300 rounded-md shadow-sm px-2 py-1 text-xs flex flex-row items-center"
            navigate={~p"/s/#{@security.symbol}"}
          >
            <%= @security.symbol %>
            <Heroicons.arrow_top_right_on_square mini class="h-4 w-4 ml-1" />
          </.link>
        </div>
      </div>
      <div class="flex flex-row overflow-x-scroll items-center gap-2 mt-2 text-sm">
        <.security_price value={Map.get(@realtime_update, :price, @security.price)} />
        <.security_change_percent value={
          Map.get(@realtime_update, :change_percent, @security.change_percent)
        } />
        <.security_change value={Map.get(@realtime_update, :change_value, @security.change_value)} />
        <.trend_badge value={@security.trend} />
        <.sector_badge value={@security.sector} />
      </div>
    </div>
    """
  end

  @doc """
  Renders a quote section for a specific security.
  """
  attr :realtime_update, :map, default: %{}
  attr :security, :map, required: true

  def watchlist_security_quote(assigns) do
    ~H"""
    <div class="flex flex-col sticky top-0 pt-2 pb-3 px-4 border border-b border-gray-200 shadow-sm">
      <div class="flex flex-row items-start justify-between space-x-4">
        <div class="flex flex-row items-center gap-2">
          <img :if={@security.image} src={@security.image} class="h-8 w-8 rounded-md object-contain" />
          <h1 class="font-semibold"><%= @security.name %> (<%= @security.symbol %>)</h1>
        </div>
        <.link
          navigate={~p"/s/#{@security.symbol}"}
          class="bg-white hover:bg-gray-100 border border-gray-300 rounded-md shadow-sm px-2 py-1 text-xs"
        >
          View
        </.link>
      </div>
      <div class="flex flex-row overflow-x-scroll items-center gap-2 mt-2 text-sm">
        <.security_price value={@security.price} />
        <.security_change_percent value={@security.change_percent} />
        <.security_change value={@security.change_value} />
        <.trend_badge value={@security.trend} />
        <.sector_badge value={@security.sector} />
      </div>
    </div>
    """
  end

  # Private

  defp class_for_value(value) do
    case value do
      0.0 -> "text-gray-500"
      value when value > 0 -> "text-green-500"
      value when value < 0 -> "text-red-500"
    end
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
    ~H"""
    <.link
      :if={@value && @value != ""}
      class="px-2 py-0.5 bg-blue-100 text-blue-500 text-xs rounded font-medium line-clamp-1"
      navigate={~p"/screener?filters[10][field]=sector&filters[10][value]=#{@value}"}
    >
      <%= @value %>
    </.link>
    """
  end

  def security_price(assigns) do
    with raw_value <- Map.get(assigns, :value, nil),
         class <- class_for_value(raw_value),
         value <- Loin.Intl.format_money_decimal(raw_value) do
      assigns =
        assigns
        |> assign(:class, class)
        |> assign(:value, value)

      ~H"""
      <span class="font-medium text-gray-700">
        <%= @value %>
      </span>
      """
    end
  end

  def security_change(assigns) do
    with raw_value <- Map.get(assigns, :value, nil),
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
    with raw_value <- Map.get(assigns, :value, nil),
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

  def trend_badge(%{value: nil} = assigns) do
    ~H"""

    """
  end

  def trend_badge(%{value: "up"} = assigns) do
    ~H"""
    <div class="text-green-500 text-xs font-medium flex items-center justify-center bg-green-100 px-2 py-0.5 rounded">
      <span>Uptrend</span>
    </div>
    """
  end

  def trend_badge(%{value: "down"} = assigns) do
    ~H"""
    <div class="text-red-500 text-xs font-medium flex items-center justify-center bg-red-100 px-2 py-0.5 rounded">
      <span>Downtrend</span>
    </div>
    """
  end

  def trend_badge(%{value: "neutral"} = assigns) do
    ~H"""
    <div class="text-gray-500 text-xs font-medium flex items-center justify-center bg-gray-100 px-2 py-0.5 rounded">
      <span>Neutral</span>
    </div>
    """
  end
end
