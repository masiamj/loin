defmodule Loin.FMP.Client do
  @moduledoc """
  This is the module for communicating with Financial Modeling Prep.
  """

  def all_profiles() do
    {:ok, %{data: []}}
  end

  def all_securities() do
    {:ok, %{data: []}}
  end

  def all_securities_peers() do
    {:ok, %{data: []}}
  end

  def batch_historical_prices(symbols) when is_list(symbols) do
    {:ok, %{
      symbols: symbols,
      data: []
    }}
  end

  def dow_jones_companies() do
    {:ok, %{data: []}}
  end

  def etf_exposure_by_stock(symbol) when is_binary(symbol) do
    {:ok,
     %{
       symbol: symbol,
       data: []
     }}
  end

  def etf_holdings(symbol) when is_binary(symbol) do
    {:ok,
     %{
       symbol: symbol,
       data: []
     }}
  end

  def etf_sector_weights(symbol) when is_binary(symbol) do
    {:ok,
     %{
       symbol: symbol,
       data: []
     }}
  end

  def nasdaq_companies() do
    {:ok, %{data: []}}
  end

  def sp500_companies() do
    {:ok,
     %{
       data: []
     }}
  end
end
