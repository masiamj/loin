defmodule LoinWeb.Lists do
  @moduledoc """
  Provides a set of list components.
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
  Renders a simple form.
  """
  attr :class, :string, default: ""
  attr :data, :list, default: []
  attr :updated_at, :string, default: nil

  def etf_constituents(assigns) do
    ~H"""
    <ul class={"grid grid-cols-1 divide-y #{@class}"}>
      <%= for %{constituent: constituent, security: security, trend: trend} <- @data do %>
        <.link navigate={~p"/s/#{security.symbol}"}>
          <li class="bg-white hover:bg-gray-100 px-2" role="button">
            <div class="flex flex-row items-center justify-between space-x-2 h-11">
              <div class="flex flex-col w-2/5">
                <div class="flex flex-row items-center gap-1">
                  <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                    <%= Map.get(security, :name) %>
                  </p>
                </div>
                <div class="flex flex-row items-center gap-1">
                  <p class="text-sm font-medium"><%= Map.get(security, :symbol) %></p>
                  <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                    (<%= Map.get(constituent, :weight_percentage) %>% weight)
                  </p>
                </div>
              </div>
              <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
                <span class="w-1/2">
                  <.security_price security={security} />
                </span>
                <span class="w-1/4">
                  <.security_change_percent security={security} />
                </span>
                <span class="hidden lg:block w-1/4">
                  <.security_change security={security} />
                </span>
              </div>
              <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
                <.trend_badge trend={trend} />
                <.trend_change_badge trend={trend} />
              </div>
            </div>
          </li>
        </.link>
      <% end %>
    </ul>
    """
  end

  @doc """
  Renders a simple form.
  """
  attr :class, :string, default: ""
  attr :data, :list, default: []
  attr :updated_at, :string, default: nil

  def etf_sector_weights(assigns) do
    ~H"""
    <ul class={"grid grid-cols-1 divide-y #{@class}"}>
      <%= for %{sector_weight: sector_weight, security: security, trend: trend} <- @data do %>
        <.link navigate={~p"/s/#{security.symbol}"}>
          <li class="bg-white hover:bg-gray-100 px-2" role="button">
            <div class="flex flex-row items-center justify-between space-x-2 h-11">
              <div class="flex flex-col w-2/5">
                <div class="flex flex-row items-center gap-1">
                  <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                    <%= Map.get(security, :symbol) %>
                  </p>
                </div>
                <div class="flex flex-row items-center gap-1">
                  <p class="text-sm font-medium"><%= Map.get(sector_weight, :name) %></p>
                  <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                    (<%= Map.get(sector_weight, :weight_percentage) %> weight)
                  </p>
                </div>
              </div>
              <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
                <span class="w-1/2">
                  <.security_price security={security} />
                </span>
                <span class="w-1/4">
                  <.security_change_percent security={security} />
                </span>
                <span class="hidden lg:block w-1/4">
                  <.security_change security={security} />
                </span>
              </div>
              <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
                <.trend_badge trend={trend} />
                <.trend_change_badge trend={trend} />
              </div>
            </div>
          </li>
        </.link>
      <% end %>
    </ul>
    """
  end

  @doc """
  Renders a simple form.
  """
  attr :class, :string, default: ""
  attr :data, :list, default: []
  attr :updated_at, :string, default: nil

  def etfs_with_exposures(assigns) do
    ~H"""
    <ul class={"grid grid-cols-1 divide-y #{@class}"}>
      <%= for %{exposure: exposure, security: security, trend: trend} <- @data do %>
        <.link navigate={~p"/s/#{security.symbol}"}>
          <li class="bg-white hover:bg-gray-100 px-2" role="button">
            <div class="flex flex-row items-center justify-between space-x-2 h-11">
              <div class="flex flex-col w-2/5">
                <div class="flex flex-row items-center gap-1">
                  <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                    <%= Map.get(security, :name) %>
                  </p>
                </div>
                <div class="flex flex-row items-center gap-1">
                  <p class="text-sm font-medium"><%= Map.get(security, :symbol) %></p>
                  <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                    (<%= Map.get(exposure, :etf_weight_percentage) %>% exposure)
                  </p>
                </div>
              </div>
              <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
                <span class="w-1/2">
                  <.security_price security={security} />
                </span>
                <span class="w-1/4">
                  <.security_change_percent security={security} />
                </span>
                <span class="hidden lg:block w-1/4">
                  <.security_change security={security} />
                </span>
              </div>
              <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
                <.trend_badge trend={trend} />
                <.trend_change_badge trend={trend} />
              </div>
            </div>
          </li>
        </.link>
      <% end %>
    </ul>
    """
  end

  @doc """
  Renders a simple form.
  """
  attr :class, :string, default: ""
  attr :data, :list, default: []
  attr :updated_at, :string, default: nil

  def similar_stocks(assigns) do
    ~H"""
    <ul class={"grid grid-cols-1 divide-y #{@class}"}>
      <%= for %{security: security, trend: trend} <- @data do %>
        <.link patch={~p"/s/#{security.symbol}"}>
          <li class="bg-white hover:bg-gray-100 px-2" role="button">
            <div class="flex flex-row items-center justify-between space-x-2 h-11">
              <div class="flex flex-col w-2/5">
                <div class="flex flex-row items-center gap-1">
                  <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                    <%= Map.get(security, :name) %>
                  </p>
                </div>
                <p class="text-sm font-medium"><%= Map.get(security, :symbol) %></p>
              </div>
              <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
                <span class="w-1/2">
                  <.security_price security={security} />
                </span>
                <span class="w-1/4">
                  <.security_change_percent security={security} />
                </span>
                <span class="hidden lg:block w-1/4">
                  <.security_change security={security} />
                </span>
              </div>
              <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
                <.trend_badge trend={trend} />
                <.trend_change_badge trend={trend} />
              </div>
            </div>
          </li>
        </.link>
      <% end %>
    </ul>
    """
  end

  @doc """
  Renders a simple form.
  """
  attr :class, :string, default: ""
  attr :data, :map, default: %{}
  attr :updated_at, :string, default: nil

  def stocks_with_trends(assigns) do
    ~H"""
    <ul class={"grid grid-cols-1 divide-y #{@class}"}>
      <%= for {symbol, %{security: security, trend: trend}} <- @data do %>
        <.link navigate={~p"/s/#{symbol}"}>
          <li class="bg-white hover:bg-gray-100 px-2" role="button">
            <div class="flex flex-row items-center justify-between space-x-2 h-11">
              <div class="flex flex-col w-2/5">
                <div class="flex flex-row items-center gap-1">
                  <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                    <%= Map.get(security, :name) %>
                  </p>
                </div>
                <p class="text-sm font-medium"><%= symbol %></p>
              </div>
              <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
                <span class="w-1/2">
                  <.security_price security={security} />
                </span>
                <span class="w-1/4">
                  <.security_change_percent security={security} />
                </span>
                <span class="hidden lg:block w-1/4">
                  <.security_change security={security} />
                </span>
              </div>
              <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
                <.trend_badge trend={trend} />
                <.trend_change_badge trend={trend} />
              </div>
            </div>
          </li>
        </.link>
      <% end %>
    </ul>
    """
  end

  defp class_for_value(value) do
    case value do
      0.0 -> "text-gray-500"
      value when value > 0 -> "text-green-500"
      value when value < 0 -> "text-red-500"
    end
  end

  defp get_change_percent(security) when is_map(security) do
    case Map.get(security, :change_percent) do
      nil -> "-"
      value when is_float(value) -> Float.round(value)
    end
  end

  defp security_price(assigns) do
    value =
      assigns
      |> Map.get(:security, %{})
      |> Map.get(:price, "-")
      |> Money.parse!()
      |> Money.to_string()

    assigns = assign(assigns, :value, value)

    ~H"""
    <span>
      <%= @value %>
    </span>
    """
  end

  defp security_change(assigns) do
    with raw_value <- Map.get(assigns.security, :change, 0.0),
         class <- class_for_value(raw_value),
         value <- raw_value |> Money.parse!() |> Money.to_string() do
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

  defp security_change_percent(assigns) do
    with value <- get_change_percent(assigns.security),
         class <- class_for_value(value) do
      assigns =
        assigns
        |> assign(:class, class)
        |> assign(:value, value)

      ~H"""
      <span class={@class}>
        <%= @value %>%
      </span>
      """
    end
  end

  defp trend_badge(assigns) when is_nil(assigns.trend),
    do: ~H"""

    """

  defp trend_badge(assigns) when is_map(assigns.trend) do
    case Map.get(assigns.trend, :trend) do
      "up" ->
        ~H"""
        <div class="text-green-500 text-xs font-medium flex items-center justify-center">
          <span>Uptrend</span>
        </div>
        """

      "down" ->
        ~H"""
        <div class="text-red-500 text-xs font-medium flex items-center justify-center">
          <span>Downtrend</span>
        </div>
        """

      "neutral" ->
        ~H"""
        <div class="text-gray-500 text-xs font-medium flex items-center justify-center">
          <span>Neutral</span>
        </div>
        """

      nil ->
        ~H"""
        <div></div>
        """
    end
  end

  defp trend_change_badge(assigns) when is_nil(assigns.trend),
    do: ~H"""

    """

  defp trend_change_badge(assigns) when is_map(assigns.trend) do
    case Map.get(assigns.trend, :trend_change) do
      tc when tc in ["down_to_up", "down_to_neutral", "neutral_to_up"] ->
        ~H"""
        <div>
          <span>⬆️</span>
        </div>
        """

      tc when tc in ["up_to_down", "up_to_neutral", "neutral_to_down"] ->
        ~H"""
        <div>
          <span>⬇️</span>
        </div>
        """

      _ ->
        ~H"""
        <div></div>
        """
    end
  end
end
