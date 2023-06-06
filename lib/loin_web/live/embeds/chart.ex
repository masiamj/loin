defmodule LoinWeb.Embeds.Chart do
  @moduledoc """
  This page represents a full-screen embeddable chart.
  """
  use LoinWeb, :live_view

  alias Loin.{
    TimeseriesCache
  }

  @impl true
  def mount(%{"symbol" => symbol}, _session, socket) do
    proper_symbol = String.upcase(symbol)
    {:ok, {^proper_symbol, chart_data}} = TimeseriesCache.get_encoded(proper_symbol)
    {:ok, %{^proper_symbol => security}} = Loin.FMP.get_securities_by_symbols([proper_symbol])

    socket =
      socket
      |> assign(:security, security)
      |> assign(:symbol, proper_symbol)
      |> assign(:timeseries_data, chart_data)

    {:ok, socket, layout: {LoinWeb.Layouts, :root}}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div
        class="h-screen w-full"
        data-timeseries={@timeseries_data}
        id="timeseries_chart"
        phx-hook="TimeseriesChart"
        phx-update="ignore"
      >
      </div>
      <div class="absolute bottom-0 left-0 bg-white p-3 border border-neutral-200 z-50">
        <p class="text-xs">
          <%= @symbol %> trend by
          <.link navigate={~p"/s/#{@symbol}"} class="text-blue-500">TrendFlares</.link>
        </p>
      </div>
      <div class="absolute top-0 right-0 z-50 text-sm">
        <.link href={~p"/screener?filters[8][field]=trend&filters[8][value]=#{@security.trend}"}>
          <.trend_badge value={@security.trend} />
        </.link>
      </div>
    </div>
    """
  end

  def trend_badge(%{value: nil} = assigns) do
    ~H"""

    """
  end

  def trend_badge(%{value: "up"} = assigns) do
    ~H"""
    <div class="text-white font-medium flex items-center justify-center bg-green-500 px-2 py-1">
      <span>Uptrend</span>
    </div>
    """
  end

  def trend_badge(%{value: "down"} = assigns) do
    ~H"""
    <div class="text-white font-medium flex items-center justify-center bg-red-500 px-2 py-1">
      <span>Downtrend</span>
    </div>
    """
  end

  def trend_badge(%{value: "neutral"} = assigns) do
    ~H"""
    <div class="text-white font-medium flex items-center justify-center bg-neutral-500 px-2 py-1">
      <span>Neutral</span>
    </div>
    """
  end
end
