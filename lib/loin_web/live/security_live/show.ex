defmodule LoinWeb.SecurityLive do
  use LoinWeb, :live_view

  @impl true
  def mount(%{"symbol" => symbol}, _session, socket) do
    serialized_data = Loin.FMP.Timeseries.get(symbol)
    |> Jason.encode!()

    socket = socket
    |> assign(:symbol, symbol)
    |> assign(:timeseries_data, serialized_data)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8">
      <div class="grid grid-cols-1">
        <LoinWeb.Cards.generic title={"#{String.upcase(@symbol)} trend"}>
          <div class="h-96 w-full" data-timeseries={@timeseries_data} id="timeseries_chart" phx-hook="TimeseriesChart" phx-update="ignore"></div>
        </LoinWeb.Cards.generic>
      </div>
    </div>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Home")
  end
end
