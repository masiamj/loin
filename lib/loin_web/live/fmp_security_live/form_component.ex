defmodule LoinWeb.FMPSecurityLive.FormComponent do
  use LoinWeb, :live_component

  alias Loin.FMP

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage fmp_security records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="fmp_security-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :description}} type="text" label="description" />
        <.input field={{f, :exchange}} type="text" label="exchange" />
        <.input field={{f, :exchange_short_name}} type="text" label="exchange_short_name" />
        <.input field={{f, :full_time_employees}} type="number" label="full_time_employees" />
        <.input field={{f, :image}} type="text" label="image" />
        <.input field={{f, :in_dow_jones}} type="checkbox" label="in_dow_jones" />
        <.input field={{f, :in_nasdaq}} type="checkbox" label="in_nasdaq" />
        <.input field={{f, :in_sp500}} type="checkbox" label="in_sp500" />
        <.input field={{f, :industry}} type="text" label="industry" />
        <.input field={{f, :is_etf}} type="checkbox" label="is_etf" />
        <.input field={{f, :market_cap}} type="number" label="market_cap" />
        <.input field={{f, :name}} type="text" label="name" />
        <.input field={{f, :sector}} type="text" label="sector" />
        <.input field={{f, :symbol}} type="text" label="symbol" />
        <.input field={{f, :website}} type="text" label="website" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Fmp security</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{fmp_security: fmp_security} = assigns, socket) do
    changeset = FMP.change_fmp_security(fmp_security)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"fmp_security" => fmp_security_params}, socket) do
    changeset =
      socket.assigns.fmp_security
      |> FMP.change_fmp_security(fmp_security_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"fmp_security" => fmp_security_params}, socket) do
    save_fmp_security(socket, socket.assigns.action, fmp_security_params)
  end

  defp save_fmp_security(socket, :edit, fmp_security_params) do
    case FMP.update_fmp_security(socket.assigns.fmp_security, fmp_security_params) do
      {:ok, _fmp_security} ->
        {:noreply,
         socket
         |> put_flash(:info, "Fmp security updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_fmp_security(socket, :new, fmp_security_params) do
    case FMP.create_fmp_security(fmp_security_params) do
      {:ok, _fmp_security} ->
        {:noreply,
         socket
         |> put_flash(:info, "Fmp security created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
