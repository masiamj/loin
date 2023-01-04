defmodule LoinWeb.RealtimeUpdateLive do
  use LoinWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    data = [1, 2, 3, 4]

    socket =
      socket
      |> assign(:data, data)

    Process.send_after(self(), :update, 1000)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8">
      <div class="grid grid-cols-4 gap-2">
        <%= for item <- @data do %>
          <div class="p-3 bg-white rounded-md shadow-md border border-gray-300">
            <p class="font-bold"><%= item %></p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info(:update, socket) do
    data = socket
    |> Map.get(:assigns)
    |> Map.get(:data, [])
    |> List.update_at(2, fn item -> item + 1 end)

    socket = socket
    |> assign(:data, data)

    Process.send_after(self(), :update, 100)
    {:noreply, socket}
  end
end
