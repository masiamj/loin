defmodule LoinWeb.DailyTrendLive.Show do
  use LoinWeb, :live_view

  alias Loin.FMP

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:daily_trend, FMP.get_daily_trend!(id))}
  end

  defp page_title(:show), do: "Show Daily trend"
  defp page_title(:edit), do: "Edit Daily trend"
end
