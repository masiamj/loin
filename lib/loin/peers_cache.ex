defmodule Loin.PeersCache do
  @moduledoc """
  This module is an interface to fetching, caching, and retrieving stock peers data.
  """
  require Logger
  alias Loin.FMP.Service

  @cache_name :peers_cache

  @doc """
  Clears the cache.
  """
  def clear(), do: Cachex.clear!(@cache_name)

  @doc """
  Gets the peers data for a symbol.
  """
  def get(symbol) when is_binary(symbol) do
    Logger.info("Starting PeersCache lookup for #{symbol}")

    result =
      Cachex.fetch(@cache_name, symbol, fn _key ->
        Logger.info("PeersCache miss for #{symbol}")
        peers_symbols = Service.peers(symbol)
        {:commit, peers_symbols}
      end)

    case result do
      {:ok, data} ->
        Logger.info("PeersCache hit for #{symbol}")
        {:ok, {symbol, data}}

      {:commit, data} when is_list(data) ->
        Logger.info("PeersCache persisted #{symbol} for 24 hour")
        Cachex.expire!(@cache_name, symbol, :timer.hours(24))
        {:ok, {symbol, data}}

      result ->
        Logger.info("Invalid PeersCache operation: #{result}")
        {:error, result}
    end
  end

  @doc """
  Gets peers prepared for the web interface.
  """
  def get_for_web(symbol) do
    Logger.info("Starting PeersCache for web lookup for #{symbol}")

    {:ok, {^symbol, peers_symbols}} = get(symbol)
    {:ok, result_map} = Loin.FMP.get_securities_by_symbols(peers_symbols)

    results =
      result_map
      |> Map.values()
      |> Enum.sort_by(& &1.market_cap, :desc)

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
