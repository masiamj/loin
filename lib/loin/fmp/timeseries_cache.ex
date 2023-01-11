defmodule Loin.FMP.TimeseriesCache do
  @moduledoc """
  This module is an interface to fetching, caching, and retrieving timeseries data.
  """
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
    result =
      Cachex.fetch(@cache_name, symbol, fn _key ->
        case Service.batch_historical_prices([symbol]) do
          %{^symbol => data} -> {:commit, {symbol, data}}
          {_symbol, data} -> {:ok, data}
          result -> {:ignore, result}
        end
      end)

    case result do
      {:ok, {^symbol, data}} ->
        data

      {:ok, data} when is_list(data) ->
        data

      {:commit, {symbol, data}} ->
        Cachex.expire!(@cache_name, symbol, :timer.hours(1))
        data

      result ->
        result
    end
  end

  @doc """
  Gets many timeseries data series.
  """
  def get_many(symbols) when is_list(symbols) do
    results =
      symbols
      |> Enum.uniq()
      |> Task.async_stream(fn symbol -> get(symbol) end, max_concurrency: 3, ordered: true)
      |> Stream.map(fn {:ok, data} -> data end)

    Enum.zip_reduce([symbols, results], %{}, fn [symbol, data], acc ->
      Map.merge(acc, %{symbol => data})
    end)
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
      |> Stream.map(fn {symbol, data} -> {symbol, data} end)
      |> Enum.to_list()

    with true <- Cachex.put_many!(@cache_name, entries, ttl: :timer.hours(24)) do
      {:ok, symbols}
    end
  end

  @doc """
  Gets cache stats.
  """
  def stats(), do: Cachex.stats(@cache_name)
end
