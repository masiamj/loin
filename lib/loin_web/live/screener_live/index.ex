defmodule LoinWeb.ScreenerLive do
  use LoinWeb, :live_view

  alias Loin.{FMP}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:filtered_data, [])
      |> assign(:meta, %{})

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8 lg:py-6">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <.form :let={f} for={@meta}>
          <Flop.Phoenix.filter_fields :let={i} form={f} fields={[:close, :name]}>
            <.input
              id={i.id}
              name={i.name}
              label={i.label}
              type={i.type}
              value={i.value}
              field={{i.form, i.field}}
              {i.rest}
            />
          </Flop.Phoenix.filter_fields>
        </.form>
        <Flop.Phoenix.table items={@filtered_data} meta={@meta} path={~p"/screener"}>
          <:col :let={item} label="Name" field={:name}><%= item.name %></:col>
          <:col :let={item} label="Age" field={:close}><%= item.close %></:col>
        </Flop.Phoenix.table>

        <Flop.Phoenix.pagination meta={@meta} path={~p"/screener"} />
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("update-filter", %{"filter" => params}, socket) do
    {:noreply, push_patch(socket, to: ~p"/screener?#{params}")}
  end

  @impl true
  def handle_event("reset-filter", _, %{assigns: assigns} = socket) do
    flop = assigns.meta.flop |> Flop.set_page(1) |> Flop.reset_filters()
    path = Flop.Phoenix.build_path(~p"/screener", flop, backend: assigns.meta.backend)
    {:noreply, push_patch(socket, to: path)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _, socket) do
    case FMP.filter_screener(params) do
      {:ok, {results, meta}} ->
        {:noreply, assign(socket, %{filtered_data: results, meta: meta})}

      _ ->
        {:noreply, push_navigate(socket, to: ~p"/screener")}
    end
  end
end
