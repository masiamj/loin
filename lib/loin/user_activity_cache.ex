defmodule Loin.UserActivityCache do
  @moduledoc """
  Caches user activities to show to others.
  """
  use GenServer
  require Logger

  # API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def page_view(:security, %{identity: identity, symbol: symbol}) do
    GenServer.cast(
      __MODULE__,
      {:put, %{href: "/s/#{symbol}", identity: identity, symbol: symbol, type: :security}}
    )
  end

  def page_view(:screener, %{identity: identity, params: params}) do
    GenServer.cast(
      __MODULE__,
      {:put, %{href: "/screener", identity: identity, params: params, type: :screener}}
    )
  end

  def all() do
    GenServer.call(__MODULE__, {:all})
  end

  # Callbacks

  @impl true
  def handle_call({:all}, _from, state) do
    {:reply, {:ok, state.activities}, state}
  end

  @impl true
  def handle_cast({:put, activity}, state) do
    activity =
      activity
      |> Map.put(:time, DateTime.utc_now())
      |> Map.put(:id, UUID.uuid4())

    state =
      state
      |> Map.put(:activities, [activity | state.activities])

    Phoenix.PubSub.broadcast(Loin.PubSub, "user_activities", {:user_activity, activity})

    {:noreply, state}
  end

  @impl true
  def handle_info(:flush, state) do
    state =
      state
      |> Map.put(:activities, Enum.take(state.activities, 50))

    schedule_flush()
    {:noreply, state}
  end

  @impl true
  def init(_opts) do
    schedule_flush()
    {:ok, %{activities: []}}
  end

  # Private
  defp schedule_flush(from_now_ms \\ 60_000) do
    Process.send_after(self(), :flush, from_now_ms)
  end
end
