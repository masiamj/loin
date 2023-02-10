defmodule LoinWeb.SectorTrends do
  @moduledoc """
  Provides a set of card components.
  """
  use LoinWeb, :live_view

  @titles_by_symbol %{
    "XLB" => "Materials",
    "XLC" => "Comms",
    "XLE" => "Energy",
    "XLF" => "Financials",
    "XLI" => "Industrials",
    "XLK" => "Tech",
    "XLP" => "Staples",
    "XLRE" => "Real Estate",
    "XLU" => "Utilities",
    "XLV" => "Healthcare",
    "XLY" => "Cyclical",
    "GLD" => "Gold"
  }

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
  Renders a heatmap of the well-defined SPDR sector ETFs with their trends.
  """
  attr :trends, :list, required: true, doc: "the list of sector daily trends"

  def heatmap(assigns) do
    ~H"""
    <div class="grid grid-cols-3 lg:grid-cols-3 gap-0.5">
      <%= for {symbol, %{trend: trend, trend_change: trend_change}} <- @trends do %>
        <.link navigate={~p"/s/#{symbol}"}>
          <div class={"p-2.5 #{background_color(trend)} rounded-sm"} role="button">
            <p class="text-gray-100 text-xs"><%= symbol %></p>
            <div class="flex items-center justify-between space-x-2">
              <p class="text-white text-sm font-medium"><%= title_for_symbol(symbol) %></p>
              <p class="text-sm"><%= emoji_for_trend_change(trend_change) %></p>
            </div>
          </div>
        </.link>
      <% end %>
    </div>
    """
  end

  defp background_color(nil), do: "bg-gray-800"

  defp background_color(trend) do
    case trend do
      "down" -> "bg-red-600"
      "neutral" -> "bg-yellow-600"
      "up" -> "bg-green-600"
      nil -> "bg-gray-600"
    end
  end

  defp emoji_for_trend_change(nil), do: ""

  defp emoji_for_trend_change(trend_change) do
    case trend_change do
      "down_to_neutral" -> "⬆️"
      "down_to_up" -> "⬆️"
      "neutral_to_down" -> "⬇️"
      "neutral_to_up" -> "⬆️"
      "up_to_down" -> "⬇️"
      "up_to_neutral" -> "⬇️"
      nil -> ""
    end
  end

  defp title_for_symbol(nil), do: "--"
  defp title_for_symbol(symbol), do: Map.get(@titles_by_symbol, symbol, "")
end
