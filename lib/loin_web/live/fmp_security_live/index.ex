defmodule LoinWeb.FMPSecurityLive.Index do
  use LoinWeb, :live_view

  alias Loin.FMP
  alias Loin.FMP.FMPSecurity

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :fmp_securities, list_fmp_securities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Fmp security")
    |> assign(:fmp_security, FMP.get_fmp_security!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Fmp security")
    |> assign(:fmp_security, %FMPSecurity{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Fmp securities")
    |> assign(:fmp_security, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    fmp_security = FMP.get_fmp_security!(id)
    {:ok, _} = FMP.delete_fmp_security(fmp_security)

    {:noreply, assign(socket, :fmp_securities, list_fmp_securities())}
  end

  defp list_fmp_securities do
    FMP.list_fmp_securities()
  end
end
