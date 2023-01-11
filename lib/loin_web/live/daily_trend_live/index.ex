defmodule LoinWeb.DailyTrendLive.Index do
  use LoinWeb, :live_view

  alias Loin.FMP
  alias Loin.FMP.DailyTrend

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :daily_trends, list_daily_trends())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Daily trend")
    |> assign(:daily_trend, FMP.get_daily_trend!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Daily trend")
    |> assign(:daily_trend, %DailyTrend{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Daily trends")
    |> assign(:daily_trend, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    daily_trend = FMP.get_daily_trend!(id)
    {:ok, _} = FMP.delete_daily_trend(daily_trend)

    {:noreply, assign(socket, :daily_trends, list_daily_trends())}
  end

  defp list_daily_trends do
    FMP.list_daily_trends()
  end
end
