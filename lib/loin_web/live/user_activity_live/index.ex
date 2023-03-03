defmodule LoinWeb.UserActivityLive do
  use LoinWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, activities} = Loin.UserActivityCache.all()

    socket =
      socket
      |> assign(:activities, uniq_by_minute(activities))

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Loin.PubSub, "user_activities")
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8 lg:py-16 bg-white max-w-3xl mx-auto">
      <h1 class="text-lg font-semibold">Live user activities</h1>
      <p class="text-sm text-gray-500 mb-4">
        This is just an experimental toy, it's a live stream of what people are doing in the system, is this cool?
      </p>
      <div class="grid grid-cols-1 divide-y" id="user-activities-container" phx-update="prepend">
        <%= for activity <- @activities do %>
          <.activity_row activity={activity} />
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info({:user_activity, activity}, socket) do
    socket =
      socket
      |> assign(:activities, uniq_by_minute([activity | socket.assigns.activities]))

    {:noreply, socket}
  end

  # Private

  defp activity_row(%{activity: %{type: :security}} = assigns) do
    ~H"""
    <.link class="p-3 bg-white hover:bg-gray-50" id={@activity.id} navigate={@activity.href}>
      <p class="text-sm">
        <%= Map.get(@assigns, :identity, %{}) |> Map.get(:first_name, "A user") %> viewed
        <span class="text-blue-600"><%= @activity.symbol %></span>
      </p>
      <p class="text-xs text-gray-500"><%= Timex.from_now(@activity.time, "Etc/UTC") %></p>
    </.link>
    """
  end

  defp activity_row(%{activity: %{type: :screener}} = assigns) do
    ~H"""
    <.link
      class="p-3 bg-white hover:bg-gray-50"
      id={@activity.id}
      navigate={~p"/screener?#{@activity.params}"}
    >
      <p class="text-sm">
        <%= Map.get(@assigns, :identity, %{}) |> Map.get(:first_name, "A user") %> ran a screener
        <span class="text-blue-600">
          <%= Map.get(@activity, :params) |> format_screener_params() %>
        </span>
      </p>
      <p class="text-xs text-gray-500"><%= Timex.from_now(@activity.time, "Etc/UTC") %></p>
    </.link>
    """
  end

  defp format_screener_params(params) do
    params
    |> Map.get("filters", %{})
    |> Map.values()
    |> Enum.map(fn item ->
      {
        humanize_field(Map.get(item, "field", nil)),
        humanize_operator(Map.get(item, "op", nil)),
        Map.get(item, "value")
      }
    end)
    |> Enum.filter(fn {field, _, value} -> !String.contains?(field, "Symbol") and value != "" end)
    |> Enum.map_join(" and ", fn {field_name, operator, value} ->
      "#{field_name} #{operator} #{value}"
    end)
  end

  defp humanize_field(field_name) when is_binary(field_name) do
    field_name
    |> String.split("_")
    |> Enum.join(" ")
    |> String.replace("ttm", "(ttm)")
  end

  defp humanize_operator(operator) do
    case operator do
      ">=" -> "above"
      "<=" -> "below"
      _ -> "is"
    end
  end

  defp uniq_by_minute(activities) when is_list(activities) do
    activities
    |> Enum.uniq_by(fn %{time: %{minute: minute}} -> minute end)
  end
end
