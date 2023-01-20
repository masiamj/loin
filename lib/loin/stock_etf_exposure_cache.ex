defmodule Loin.StockETFExposureCache do
  @moduledoc """
  This module is an interface to fetching, caching, and retrieving ETF exposure for a specific stock.
  """
  require Logger
  alias Loin.FMP.Service

  @cache_name :stock_etf_exposure_cache

  @doc """
  Clears the cache.
  """
  def clear(), do: Cachex.clear!(@cache_name)

  @doc """
  Gets the ETFs exposed to a specific symbol.
  """
  def get(symbol) when is_binary(symbol) do
    Logger.info("Starting StockETFExposureCache lookup for #{symbol}")

    result =
      Cachex.fetch(@cache_name, symbol, fn _key ->
        Logger.info("StockETFExposureCache miss for #{symbol}")
        etfs = Service.etf_exposure_by_stock(symbol)
        {:commit, etfs}
      end)

    case result do
      {:ok, data} ->
        Logger.info("StockETFExposureCache hit for #{symbol}")
        {:ok, {symbol, data}}

      {:commit, data} when is_list(data) ->
        Logger.info("StockETFExposureCache persisted #{symbol} for 24 hour")
        Cachex.expire!(@cache_name, symbol, :timer.hours(24))
        {:ok, {symbol, data}}

      result ->
        Logger.info("Invalid StockETFExposureCache operation: #{result}")
        {:error, result}
    end
  end

  @doc """
  Gets ETF exposure prepared for the web interface.
  """
  def get_for_web(symbol) when is_binary(symbol) do
    Logger.info("Starting StockETFExposureCache for web lookup for #{symbol}")

    {:ok, {^symbol, exposures}} = get(symbol)

    {:ok, result_map} =
      exposures
      |> Enum.map(&Map.get(&1, :etf_symbol))
      |> Loin.FMP.get_securities_by_symbols()

    results =
      exposures
      |> Enum.reduce([], fn %{etf_symbol: symbol} = exposure, acc ->
        case Map.has_key?(result_map, symbol) do
          true ->
            result_map
            |> Map.get(symbol, %{})
            |> Map.put(:exposure, exposure)
            |> then(fn item -> [item | acc] end)

          false ->
            acc
        end
      end)
      |> Enum.sort_by(& &1.exposure.etf_weight_percentage, :desc)

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
