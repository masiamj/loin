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
    {:ok, securities_map} = get_securities_map(buffer)

    buffer
    |> Flow.from_enumerable()
    |> Flow.partition()
    |> Flow.map(fn {symbol, price} ->
      {symbol, compute_derived_price_information(Map.get(securities_map, symbol, nil), price)}
    end)
    |> Flow.filter(fn {_symbol, result} -> is_map(result) end)
    |> Enum.to_list()
    |> Enum.each(&publish_realtime_quote/1)

    schedule_flush()
    {:noreply, %{buffer: %{}}}
  end

  @impl true
  def init(_opts) do
    schedule_flush()
    {:ok, %{buffer: %{}}}
  end

  # Private

  defp compute_derived_price_information(existing_security, price)
       when is_map(existing_security) and is_number(price) do
    previous_close = Map.get(existing_security, :fmp_securities_previous_close, price)

    %{
      price: price,
      change_value: price - previous_close,
      change_percent: (price - previous_close) / previous_close * 100
    }
  end

  defp compute_derived_price_information(_existing_security, _price), do: nil

  defp get_securities_map(buffer) when is_map(buffer) do
    buffer
    |> Map.keys()
    |> Loin.FMP.get_securities_by_symbols()
  end

  defp publish_realtime_quote({symbol, derived_price_information}) do
    Phoenix.PubSub.broadcast(
      Loin.PubSub,
      "realtime_quotes",
      {:realtime_quote, {symbol, derived_price_information}}
    )
  end

  defp schedule_flush(from_now_ms \\ 1000) do
    Process.send_after(self(), :flush, from_now_ms)
  end
end
