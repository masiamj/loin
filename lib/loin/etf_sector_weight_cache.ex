defmodule Loin.ETFSectorWeightCache do
  @moduledoc """
  This module is an interface to fetching, caching, and retrieving ETF sector weights.
  """
  require Logger
  alias Loin.FMP.Service

  @cache_name :etf_sector_weight_cache

  @symbols_by_title %{
    "Industrials" => "XLI",
    "Financial Services" => "XLF",
    "Consumer Cyclical" => "XLY",
    "Healthcare" => "XLV",
    "Basic Materials" => "XLB",
    "Communication Services" => "XLC",
    "Energy" => "XLE",
    "Consumer Defensive" => "XLP",
    "Technology" => "XLK",
    "Real Estate" => "XLRE",
    "Utilities" => "XLU"
  }

  @titles_by_symbol %{
    "XLB" => "Materials",
    "XLC" => "Communications",
    "XLE" => "Energy",
    "XLF" => "Financials",
    "XLI" => "Industrials",
    "XLK" => "Technology",
    "XLP" => "Consumer Staples",
    "XLRE" => "Real Estate",
    "XLU" => "Utilities",
    "XLV" => "Healthcare",
    "XLY" => "Consumer Discretionary",
    "GLD" => "Gold"
  }

  @doc """
  Clears the cache.
  """
  def clear(), do: Cachex.clear!(@cache_name)

  @doc """
  Gets the ETF's sector weighting.
  """
  def get(symbol) when is_binary(symbol) do
    Logger.info("Starting ETFSectorWeightCache lookup for #{symbol}")

    result =
      Cachex.fetch(@cache_name, symbol, fn _key ->
        Logger.info("ETFSectorWeightCache miss for #{symbol}")
        sector_weights = Service.etf_sector_weights(symbol)
        {:commit, sector_weights}
      end)

    case result do
      {:ok, data} ->
        Logger.info("ETFSectorWeightCache hit for #{symbol}")
        {:ok, {symbol, data}}

      {:commit, data} when is_list(data) ->
        Logger.info("ETFSectorWeightCache persisted #{symbol} for 24 hour")
        Cachex.expire!(@cache_name, symbol, :timer.hours(24))
        {:ok, {symbol, data}}

      result ->
        Logger.info("Invalid ETFSectorWeightCache operation: #{result}")
        {:error, result}
    end
  end

  @doc """
  Gets ETF exposure prepared for the web interface.
  """
  def get_for_web(symbol) when is_binary(symbol) do
    Logger.info("Starting ETFSectorWeightCache for web lookup for #{symbol}")

    {:ok, {^symbol, sector_weights}} = get(symbol)

    {:ok, result_map} =
      Loin.FMP.get_securities_by_symbols([
        "XLB",
        "XLC",
        "XLE",
        "XLF",
        "XLI",
        "XLK",
        "XLP",
        "XLRE",
        "XLU",
        "XLV",
        "XLY"
      ])

    results =
      sector_weights
      |> Enum.reduce([], fn sector_weight, acc ->
        sector_name = Map.get(sector_weight, :sector)
        sector_etf_symbol = Map.get(@symbols_by_title, sector_name)
        sector_etf_title = Map.get(@titles_by_symbol, sector_etf_symbol)

        case Map.has_key?(result_map, sector_etf_symbol) do
          true ->
            result_map
            |> Map.get(sector_etf_symbol, %{})
            |> Map.put(:sector_weight, Map.put(sector_weight, :name, sector_etf_title))
            |> then(fn item -> [item | acc] end)

          false ->
            acc
        end
      end)
      |> Enum.sort_by(& &1.sector_weight.weight_percentage, :desc)

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
