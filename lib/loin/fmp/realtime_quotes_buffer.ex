defmodule Loin.FMP.RealtimeQuotesBuffer do
  @moduledoc """
  Buffers the realtime quotes before writing to a persistent store.
  """
  use GenServer
  require Logger

  # API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def put({symbol, latest_price}) do
    GenServer.cast(__MODULE__, {:put, {symbol, latest_price}})
  end

  # Callbacks

  @impl true
  def handle_cast({:put, {symbol, latest_price}}, state) do
    state =
      Map.update(state, :buffer, %{}, fn buffer -> Map.put(buffer, symbol, latest_price) end)

    {:noreply, state}
  end

  @impl true
  def handle_info(:flush, %{buffer: buffer} = _state) do
    Enum.each(buffer, fn {symbol, price} ->
      Phoenix.PubSub.broadcast(
        Loin.PubSub,
        "realtime_quotes",
        {:realtime_quote, {symbol, %{price: price}}}
      )
    end)

    schedule_flush()
    {:noreply, %{buffer: %{}}}
  end

  @impl true
  def init(_opts) do
    schedule_flush()
    {:ok, %{buffer: %{}}}
  end

  # Private

  def schedule_flush(from_now_ms \\ 1000) do
    Process.send_after(self(), :flush, from_now_ms)
  end
end
