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
              <p class="text-sm font-medium"><%= Map.get(@item.security, :symbol) %></p>
              <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                (<%= Map.get(@item.constituent, :weight_percentage) %>% weight)
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
            <span class="w-1/4">
              <.security_change security={@item.security} />
            </span>
          </div>
          <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
            <.trend_badge trend={@item.trend} />
            <.trend_change_badge trend={@item.trend} />
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
                (<%= Map.get(@item.sector_weight, :weight_percentage) %> weight)
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
            <span class="w-1/4">
              <.security_change security={@item.security} />
            </span>
          </div>
          <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
            <.trend_badge trend={@item.trend} />
            <.trend_change_badge trend={@item.trend} />
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
              <p class="text-sm font-medium"><%= Map.get(@item.security, :symbol) %></p>
              <p class="text-xs text-gray-500 line-clamp-1" style="font-size:10px;">
                (<%= Map.get(@item.exposure, :etf_weight_percentage) %>% exposure)
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
            <span class="w-1/4">
              <.security_change security={@item.security} />
            </span>
          </div>
          <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
            <.trend_badge trend={@item.trend} />
            <.trend_change_badge trend={@item.trend} />
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
            <p class="text-sm font-medium"><%= Map.get(@item.security, :symbol) %></p>
          </div>
          <div class="flex flex-row items-center justify-between w-2/5 space-x-3 text-xs">
            <span class="w-1/2">
              <.security_price security={@item.security} />
            </span>
            <span class="w-1/4">
              <.security_change_percent security={@item.security} />
            </span>
            <span class="w-1/4">
              <.security_change security={@item.security} />
            </span>
          </div>
          <div class="flex flex-row items-center justify-end space-x-1 w-1/5">
            <.trend_badge trend={@item.trend} />
            <.trend_change_badge trend={@item.trend} />
          </div>
        </div>
      </li>
    </.link>
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

  def security_price(assigns) do
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

  def security_change(assigns) do
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

  def security_change_percent(assigns) do
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

  defp trend_badge(%{trend: nil} = assigns) do
    ~H"""

    """
  end

  defp trend_badge(%{trend: %{trend: "up"}} = assigns) do
    ~H"""
    <div class="text-green-500 text-xs font-medium flex items-center justify-center">
      <span>Uptrend</span>
    </div>
    """
  end

  defp trend_badge(%{trend: %{trend: "down"}} = assigns) do
    ~H"""
    <div class="text-red-500 text-xs font-medium flex items-center justify-center">
      <span>Downtrend</span>
    </div>
    """
  end

  defp trend_badge(%{trend: %{trend: "neutral"}} = assigns) do
    ~H"""
    <div class="text-gray-500 text-xs font-medium flex items-center justify-center">
      <span>Neutral</span>
    </div>
    """
  end

  defp trend_badge(%{trend: %{trend: nil}} = assigns) do
    ~H"""
    <div></div>
    """
  end

  defp trend_change_badge(%{trend: nil} = assigns) do
    ~H"""

    """
  end

  defp trend_change_badge(%{trend: %{trend_change: trend_change}} = assigns)
       when trend_change in ["down_to_up", "down_to_neutral", "neutral_to_up"] do
    ~H"""
    <div>
      <span>⬆️</span>
    </div>
    """
  end

  defp trend_change_badge(%{trend: %{trend_change: trend_change}} = assigns)
       when trend_change in ["up_to_down", "up_to_neutral", "neutral_to_down"] do
    ~H"""
    <div>
      <span>⬇️</span>
    </div>
    """
  end

  defp trend_change_badge(%{trend: %{trend_change: _}} = assigns) do
    ~H"""
    <div></div>
    """
  end
end
