defmodule Loin.FMP.SectorTrendsCache do
  @moduledoc """
  This module is an interface to caching and retrieving the sector trends.
  """
  alias Loin.Repo
  alias Loin.FMP.{DailyTrend}
  import Ecto.Query

  @cache_name :sector_trends
  @sector_trends_key "sector_trends_key"
  @supported_symbols [
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
    "XLY",
    "GLD"
  ]

  @doc """
  Clears the cache.
  """
  def clear(), do: Cachex.clear!(@cache_name)

  @doc """
  Gets all the sector trends.
  """
  def all() do
    result =
      Cachex.fetch(@cache_name, @sector_trends_key, fn _key ->
        {:ok, trends} = setup()
        {:commit, {@sector_trends_key, trends}}
      end)

    case result do
      {:ok, {@sector_trends_key, trends}} ->
        trends

      {:commit, {@sector_trends_key, trends}} ->
        Cachex.expire!(@cache_name, @sector_trends_key, :timer.hours(1))
        trends

      result ->
        result
    end
  end

  @doc """
  Gets cache keys.
  """
  def keys(), do: Cachex.keys(@cache_name)

  @doc """
  Caches the sector trends.
  """
  def setup() do
    entries =
      DailyTrend
      |> where([dt], dt.symbol in ^@supported_symbols)
      |> order_by(asc: :symbol)
      |> Repo.all()

    {:ok, true} = Cachex.put(@cache_name, @sector_trends_key, entries, ttl: :timer.hours(1))
    {:ok, entries}
  end

  @doc """
  Gets cache stats.
  """
  def stats(), do: Cachex.stats(@cache_name)
end
