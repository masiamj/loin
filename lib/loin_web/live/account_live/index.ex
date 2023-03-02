defmodule LoinWeb.AccountLive do
  use LoinWeb, :live_view

  alias Loin.Accounts

  def render(assigns) do
    ~H"""
    <div class="w-full lg:max-w-md mx-auto px-8 lg:px-0 py-8">
      <div>
        <h1 class="text-3xl font-bold">My account</h1>
      </div>
      <div class="grid grid-cols-1 divide-y mt-8">
        <div class="pb-8">
          <p class="font-semibold -mb-8">Your email</p>
          <.simple_form :let={f} id="email_form" for={@names_changeset}>
            <.input field={{f, :email}} type="email" label="Email" required disabled />
          </.simple_form>
          <p class="text-xs text-gray-500 mt-2">
            If you need to change your email, please contact us as
            <a class="text-blue-500" href="mailto:support@trendflares.com">support@trendflares.com</a>
          </p>
        </div>
        <div class="pb-8">
          <p class="font-semibold -mb-8 mt-8">Your name</p>
          <.simple_form
            :let={f}
            id="names_form"
            for={@names_changeset}
            phx-submit="update_names"
            phx-change="validate_names"
          >
            <.error :if={@names_changeset.action == :insert}>
              Oops, something went wrong! Please check the errors below.
            </.error>

            <.input field={{f, :first_name}} type="text" label="First name" required />
            <.input field={{f, :last_name}} type="text" label="Last name" required />

            <:actions>
              <.button phx-disable-with="Saving...">Update name</.button>
            </:actions>
          </.simple_form>
        </div>
        <div>
          <p class="font-semibold mt-8 text-red-500">Danger zone</p>
          <div class="mt-4">
            <.link href={~p"/identities/log_out"} method="delete">
              <.button class="bg-red-600 hover:bg-red-700">Log out</.button>
            </.link>
          </div>
          <div class="mt-8">
            <p class="text-xs text-gray-500">
              If you need to delete your account, please contact us as
              <a class="text-blue-500" href="mailto:support@trendflares.com">
                support@trendflares.com
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>
    <LoinWeb.FooterComponents.footer />
    """
  end

  def mount(_params, _session, socket) do
    current_identity = socket.assigns.current_identity

    socket =
      socket
      |> assign(:names_changeset, Accounts.change_identity(current_identity))

    {:ok, socket}
  end

  def handle_event(
        "validate_names",
        %{"identity" => identity_params},
        socket
      ) do
    names_changeset = Accounts.change_identity(socket.assigns.current_identity, identity_params)

    socket =
      socket
      |> assign(:names_changeset, Map.put(names_changeset, :action, :validate))

    {:noreply, socket}
  end

  def handle_event(
        "update_names",
        %{"identity" => identity_params},
        socket
      ) do
    current_identity = socket.assigns.current_identity

    case Accounts.update_identity(current_identity, identity_params) do
      {:ok, _identity} ->
        {:noreply, put_flash(socket, :info, "Name changed!")}

      {:error, changeset} ->
        {:noreply, assign(socket, :names_changeset, Map.put(changeset, :action, :insert))}
    end
  end
end
