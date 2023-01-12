defmodule LoinWeb.SecurityLive do
  use LoinWeb, :live_view

  @impl true
  def mount(%{"symbol" => symbol}, _session, socket) do
    proper_symbol = String.upcase(symbol)

    case fetch_chart_data(proper_symbol) do
      {:ok, chart_data} ->
        socket =
          socket
          |> assign(:symbol, symbol)
          |> assign(:timeseries_data, chart_data)

        {:ok, socket}

      _result ->
        socket =
          socket
          |> assign(:symbol, symbol)
          |> assign(:timeseries_data, [])

        {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8">
      <div class="grid grid-cols-1">
        <LoinWeb.Cards.generic title={"#{String.upcase(@symbol)} trend"}>
          <div
            class="h-96 w-full"
            data-timeseries={@timeseries_data}
            id="timeseries_chart"
            phx-hook="TimeseriesChart"
            phx-update="ignore"
          >
          </div>
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

  defp fetch_chart_data(symbol) do
    {:ok, {^symbol, data}} =
      symbol
      |> String.upcase()
      |> Loin.TimeseriesCache.get()

    Jason.encode(data)
  end
end
