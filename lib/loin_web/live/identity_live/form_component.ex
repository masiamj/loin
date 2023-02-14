defmodule LoinWeb.IdentityLive.FormComponent do
  use LoinWeb, :live_component

  alias Loin.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage identity records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="identity-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :first_name}} type="text" label="first_name" />
        <.input field={{f, :last_name}} type="text" label="last_name" />
        <.input field={{f, :image_url}} type="text" label="image_url" />
        <.input field={{f, :email}} type="text" label="email" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Identity</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{identity: identity} = assigns, socket) do
    changeset = Accounts.change_identity(identity)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"identity" => identity_params}, socket) do
    changeset =
      socket.assigns.identity
      |> Accounts.change_identity(identity_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"identity" => identity_params}, socket) do
    save_identity(socket, socket.assigns.action, identity_params)
  end

  defp save_identity(socket, :edit, identity_params) do
    case Accounts.update_identity(socket.assigns.identity, identity_params) do
      {:ok, _identity} ->
        {:noreply,
         socket
         |> put_flash(:info, "Identity updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_identity(socket, :new, identity_params) do
    case Accounts.create_identity(identity_params) do
      {:ok, _identity} ->
        {:noreply,
         socket
         |> put_flash(:info, "Identity created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
