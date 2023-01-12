defmodule LoinWeb.Lists do
  @moduledoc """
  Provides a set of list components.
  """
  use Phoenix.Component

  @doc """
  Renders a simple form.
  """
  attr :class, :string, default: ""
  attr :data, :list, default: []
  attr :updated_at, :string, default: nil

  def stocks_with_trends(assigns) do
    ~H"""
    <ul class={"grid grid-cols-1 divide-y #{@class}"}>
      <%= for %{security: security, trend: trend} <- @data do %>
        <li class="bg-white hover:bg-gray-100 p-2" role="button">
          <div class="flex flex-row items-center justify-between space-x-2">
            <div class="flex flex-col w-2/5">
              <div class="flex flex-row items-center gap-1">
                <p class="text-xs text-gray-400" style="font-size:10px;">
                  <%= Map.get(security, :exchange_short_name) %>:<%= Map.get(security, :symbol) %>
                </p>
                <Heroicons.arrow_top_right_on_square
                  :if={Map.get(security, :website)}
                  class="h-3 w-3 text-gray-400"
                />
              </div>
              <p class="text-sm font-medium"><%= Map.get(security, :name) %></p>
            </div>
            <div class="flex flex-col w-2/5">
              <p class="text-xs text-gray-400" style="font-size:10px;">Close</p>
              <p class="text-sm">
                <%= Map.get(trend, :close) |> Money.parse!() |> Money.to_string() %>
              </p>
            </div>
            <div class="flex flex-row items-center justify-end space-x-2 w-1/5">
              <.trend_change_badge trend_change={Map.get(trend, :trend_change)} />
              <.trend_badge trend={Map.get(trend, :trend)} />
            </div>
          </div>
        </li>
      <% end %>
    </ul>
    """
  end

  defp trend_badge(assigns) do
    case assigns.trend do
      "up" ->
        ~H"""
        <div class="px-2 py-1 border border-green-500 text-green-500 bg-green-50 rounded-md text-xs flex items-center justify-center">
          <span>Up</span>
        </div>
        """

      "down" ->
        ~H"""
        <div class="px-2 py-1 border border-red-500 text-red-500 bg-red-50 rounded-md text-xs flex items-center justify-center">
          <span>Down</span>
        </div>
        """

      "neutral" ->
        ~H"""
        <div class="px-2 py-1 border border-gray-500 text-gray-500 bg-gray-50 rounded-md text-xs flex items-center justify-center">
          <span>Neutral</span>
        </div>
        """

      nil ->
        ~H"""
        <div></div>
        """
    end
  end

  defp trend_change_badge(assigns) do
    case assigns.trend_change do
      tc when tc in ["down_to_neutral", "neutral_to_up"] ->
        ~H"""
        <div>
          <span>⬆️</span>
        </div>
        """

      tc when tc in ["up_to_neutral", "neutral_to_down"] ->
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
