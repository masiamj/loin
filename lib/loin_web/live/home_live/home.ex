defmodule LoinWeb.HomeLive do
  use LoinWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>On the page</h1>
      <div class="w-124 h-48s" id="example-chart" phx-hook="ExampleChart"></div>
    </div>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :home, _params) do
    socket
    |> assign(:page_title, "Home")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:noreply, socket}
  end
end
