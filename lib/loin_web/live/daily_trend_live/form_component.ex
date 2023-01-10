defmodule LoinWeb.DailyTrendLive.FormComponent do
  use LoinWeb, :live_component

  alias Loin.FMP

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage daily_trend records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="daily_trend-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :close}} type="number" label="close" step="any" />
        <.input field={{f, :close_above_day_200_sma}} type="checkbox" label="close_above_day_200_sma" />
        <.input field={{f, :close_above_day_50_sma}} type="checkbox" label="close_above_day_50_sma" />
        <.input field={{f, :date}} type="date" label="date" />
        <.input field={{f, :day_200_sma}} type="number" label="day_200_sma" step="any" />
        <.input field={{f, :day_50_sma}} type="number" label="day_50_sma" step="any" />
        <.input
          field={{f, :day_50_sma_above_day_200_sma}}
          type="checkbox"
          label="day_50_sma_above_day_200_sma"
        />
        <.input field={{f, :is_valid}} type="checkbox" label="is_valid" />
        <.input field={{f, :previous_close}} type="number" label="previous_close" step="any" />
        <.input
          field={{f, :previous_close_above_day_200_sma}}
          type="checkbox"
          label="previous_close_above_day_200_sma"
        />
        <.input
          field={{f, :previous_close_above_day_50_sma}}
          type="checkbox"
          label="previous_close_above_day_50_sma"
        />
        <.input
          field={{f, :previous_day_200_sma}}
          type="number"
          label="previous_day_200_sma"
          step="any"
        />
        <.input
          field={{f, :previous_day_50_sma}}
          type="number"
          label="previous_day_50_sma"
          step="any"
        />
        <.input
          field={{f, :previous_day_50_sma_above_day_200_sma}}
          type="checkbox"
          label="previous_day_50_sma_above_day_200_sma"
        />
        <.input field={{f, :previous_trend}} type="text" label="previous_trend" />
        <.input
          field={{f, :previous_truthy_flags_count}}
          type="number"
          label="previous_truthy_flags_count"
        />
        <.input field={{f, :symbol}} type="text" label="symbol" />
        <.input field={{f, :trend}} type="text" label="trend" />
        <.input field={{f, :trend_change}} type="text" label="trend_change" />
        <.input field={{f, :truthy_flags_count}} type="number" label="truthy_flags_count" />
        <.input field={{f, :volume}} type="number" label="volume" step="any" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Daily trend</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{daily_trend: daily_trend} = assigns, socket) do
    changeset = FMP.change_daily_trend(daily_trend)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"daily_trend" => daily_trend_params}, socket) do
    changeset =
      socket.assigns.daily_trend
      |> FMP.change_daily_trend(daily_trend_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"daily_trend" => daily_trend_params}, socket) do
    save_daily_trend(socket, socket.assigns.action, daily_trend_params)
  end

  defp save_daily_trend(socket, :edit, daily_trend_params) do
    case FMP.update_daily_trend(socket.assigns.daily_trend, daily_trend_params) do
      {:ok, _daily_trend} ->
        {:noreply,
         socket
         |> put_flash(:info, "Daily trend updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_daily_trend(socket, :new, daily_trend_params) do
    case FMP.create_daily_trend(daily_trend_params) do
      {:ok, _daily_trend} ->
        {:noreply,
         socket
         |> put_flash(:info, "Daily trend created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
