defmodule LoinWeb.IdentityLive.Index do
  use LoinWeb, :live_view

  alias Loin.Accounts
  alias Loin.Accounts.Identity

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :identities, list_identities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Identity")
    |> assign(:identity, Accounts.get_identity!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Identity")
    |> assign(:identity, %Identity{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Identities")
    |> assign(:identity, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    identity = Accounts.get_identity!(id)
    {:ok, _} = Accounts.delete_identity(identity)

    {:noreply, assign(socket, :identities, list_identities())}
  end

  defp list_identities do
    Accounts.list_identities()
  end
end
