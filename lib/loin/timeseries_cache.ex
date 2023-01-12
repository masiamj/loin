defmodule Loin.TimeseriesCache do
  @moduledoc """
  This module is an interface to fetching, caching, and retrieving timeseries data.
  """
  require Logger
  alias Loin.FMP.Service

  @cache_name :timeseries_data

  @doc """
  Clears the cache.
  """
  def clear(), do: Cachex.clear!(@cache_name)

  @doc """
  Gets the timeseries data for a symbol.
  """
  def get(symbol) when is_binary(symbol) do
    Logger.info("Starting TimeseriesCache lookup for #{symbol}")

    result =
      Cachex.fetch(@cache_name, symbol, fn _key ->
        # This is a fallback for reactive cache warming
        Logger.info("TimeseriesCache miss for #{symbol}")

        case Service.batch_historical_prices([symbol]) do
          %{^symbol => data} -> {:commit, data}
          %{} -> {:ignore}
        end
      end)

    case result do
      {:ok, data} ->
        Logger.info("TimeseriesCache hit for #{symbol}")
        {:ok, {symbol, data}}

      {:commit, data} when is_list(data) ->
        Logger.info("TimeseriesCache persisted #{symbol} for 1 hour")
        Cachex.expire!(@cache_name, symbol, :timer.hours(1))
        {:ok, {symbol, data}}

      result ->
        Logger.info("Invalid TimeseriesCache operation: #{result}")
        {:error, result}
    end
  end

  @doc """
  Gets many timeseries data series.
  """
  def get_many(symbols) when is_list(symbols) do
    Logger.info("Starting Batch TimeseriesCache lookup for #{Enum.join(symbols, ", ")}")

    results =
      symbols
      |> Enum.uniq()
      |> Task.async_stream(fn symbol -> get(symbol) end, max_concurrency: 3, ordered: true)
      |> Stream.map(fn {:ok, {:ok, {symbol, data}}} -> {symbol, data} end)
      |> Enum.into(%{})

    {:ok, results}
  end

  @doc """
  Gets cache keys.
  """
  def keys(), do: Cachex.keys(@cache_name)

  @doc """
  Caches many symbols at once.
  """
  def put_many(symbols) when is_list(symbols) do
    entries =
      symbols
      |> Enum.uniq()
      |> Enum.chunk_every(5)
      |> Task.async_stream(fn chunk -> Service.batch_historical_prices(chunk) end,
        max_concurrency: 3,
        ordered: true
      )
      |> Stream.flat_map(fn {:ok, result_map} -> result_map end)
      |> Enum.into([])

    with true <- Cachex.put_many!(@cache_name, entries, ttl: :timer.hours(1)) do
      {:ok, symbols}
    end
  end

  @doc """
  Gets cache stats.
  """
  def stats(), do: Cachex.stats(@cache_name)
end
