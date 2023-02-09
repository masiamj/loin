defmodule Loin.ETFConstituentsCache do
  @moduledoc """
  This module is an interface to fetching, caching, and retrieving ETF constituents.
  """
  require Logger
  alias Loin.FMP.Service

  @cache_name :etf_constituents_cache

  @doc """
  Clears the cache.
  """
  def clear(), do: Cachex.clear!(@cache_name)

  @doc """
  Gets the ETF's constituents.
  """
  def get(symbol) when is_binary(symbol) do
    Logger.info("Starting ETFConstituentsCache lookup for #{symbol}")

    result =
      Cachex.fetch(@cache_name, symbol, fn _key ->
        Logger.info("ETFConstituentsCache miss for #{symbol}")
        constituents = Service.etf_holdings(symbol)
        {:commit, constituents}
      end)

    case result do
      {:ok, data} ->
        Logger.info("ETFConstituentsCache hit for #{symbol}")
        {:ok, {symbol, data}}

      {:commit, data} when is_list(data) ->
        Logger.info("ETFConstituentsCache persisted #{symbol} for 24 hour")
        Cachex.expire!(@cache_name, symbol, :timer.hours(24))
        {:ok, {symbol, data}}

      result ->
        Logger.info("Invalid ETFConstituentsCache operation: #{result}")
        {:error, result}
    end
  end

  @doc """
  Gets ETF constituents prepared for the web interface.
  """
  def get_for_web(symbol) when is_binary(symbol) do
    Logger.info("Starting ETFConstituentsCache for web lookup for #{symbol}")

    {:ok, {^symbol, constituents}} = get(symbol)

    {:ok, result_map} =
      constituents
      |> Enum.map(&Map.get(&1, :symbol))
      |> Loin.FMP.get_securities_by_symbols()

    results =
      constituents
      |> Enum.reduce([], fn %{symbol: symbol} = constituent, acc ->
        case Map.has_key?(result_map, symbol) do
          true ->
            result_map
            |> Map.get(symbol, %{})
            |> Map.put(:constituent, constituent)
            |> then(fn item -> [item | acc] end)

          false ->
            acc
        end
      end)
      |> Enum.sort_by(& &1.constituent.weight_percentage, :desc)

    {:ok, results}
  end

  @doc """
  Gets cache keys.
  """
  def keys(), do: Cachex.keys(@cache_name)

  @doc """
  Gets cache stats.
  """
  def stats(), do: Cachex.stats(@cache_name)
end
