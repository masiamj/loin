defmodule LoinWeb.Embeds.Chart do
  use LoinWeb, :live_view

  alias Loin.{
    TimeseriesCache
  }

  @impl true
  def mount(%{"symbol" => symbol}, _session, socket) do
    proper_symbol = String.upcase(symbol)
    {:ok, {^proper_symbol, chart_data}} = TimeseriesCache.get_encoded(proper_symbol)

    socket =
      socket
      |> assign(:symbol, proper_symbol)
      |> assign(:timeseries_data, chart_data)
      |> assign(:realtime_update, nil)

    publish()

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
        data-realtime-update={@realtime_update}
      >
      </div>
      <div class="absolute top-0 left-0 bg-white p-3 border border-gray-200 z-50">
        <p class="text-sm">
          <%= @symbol %> trend powered by
          <.link patch={~p"/s/#{@symbol}"} class="text-blue-500">TrendFlares</.link>
        </p>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info(:realtime_quote, socket) do
    socket =
      socket
      |> assign(:realtime_update, %{price: Enum.random(200..220)} |> Jason.encode!())

    publish()
    {:noreply, socket}
  end

  def publish() do
    Process.send_after(self(), :realtime_quote, 1000)
  end
end
