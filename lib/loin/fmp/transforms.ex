defmodule Loin.FMP.Transforms do
  @moduledoc """
  Defines common data cleaners and transforms for raw FMP data.
  """

  alias Loin.FMP.MajorIndexSymbolsCache

  @doc """
  Transforms a FMP ETF stock exposure to an application-level security.
  """
  def etf_exposure(security) when is_map(security) do
    %{
      asset_symbol: Map.get(security, "assetExposure"),
      etf_symbol: Map.get(security, "etfSymbol"),
      etf_weight_percentage: Map.get(security, "weightPercentage")
    }
  end

  @doc """
  Transforms a FMP ETF stock holding to an application-level security.
  """
  def etf_holding(security) when is_map(security) do
    %{
      name: Map.get(security, "name"),
      symbol: Map.get(security, "asset"),
      weight_percentage: Map.get(security, "weightPercentage"),
      updated_at: Map.get(security, "updated")
    }
  end

  @doc """
  Transforms a FMP ETF sector weighting to an application-level structure.
  """
  def etf_sector_weight(security) when is_map(security) do
    %{
      sector: Map.get(security, "sector"),
      weight_percentage: Map.get(security, "weightPercentage")
    }
  end

  @doc """
  Maps a historical price item into the proper application-level structure.
  """
  def historical_prices(%{"symbol" => symbol, "historical" => historical})
      when is_list(historical) do
    data =
      historical
      |> Enum.map(fn item ->
        %{
          close: Map.get(item, "adjClose"),
          date: Map.get(item, "date"),
          volume: Map.get(item, "volume")
        }
      end)
      |> Enum.reverse()

    %{data: data, symbol: symbol}
  end

  @doc """
  Maps a raw peers entry to an application-level peers entry.
  """
  def peers(security) when is_map(security) do
    %{
      peers: Map.get(security, "peersList", []),
      symbol: Map.get(security, "symbol")
    }
  end

  @doc """
  Maps a raw Profile to an application-level security.
  """
  def profile(%{"Symbol" => symbol} = security) when is_map(security) do
    %{
      description: Map.get(security, "description"),
      exchange: Map.get(security, "exchange"),
      exchange_short_name: Map.get(security, "exchangeShortName"),
      full_time_employees: Map.get(security, "fullTimeEmployees"),
      image: Map.get(security, "image"),
      in_dow_jones: MajorIndexSymbolsCache.is_dow_jones(symbol),
      in_nasdaq: MajorIndexSymbolsCache.is_nasdaq(symbol),
      in_sp500: MajorIndexSymbolsCache.is_sp500(symbol),
      industry: Map.get(security, "industry"),
      is_etf: Map.get(security, "isEtf") == "TRUE",
      market_cap: Map.get(security, "mktCap"),
      name: Map.get(security, "companyName"),
      sector: Map.get(security, "sector"),
      symbol: symbol,
      website: Map.get(security, "website")
    }
  end

  @doc """
  Transforms a FMP ETF constituent to an application-level security for the well-known
  indices (S&P 500, Nasdaq, Dow Jones).
  """
  def well_defined_constituent(security) when is_map(security) do
    %{
      name: Map.get(security, "name"),
      sector: Map.get(security, "sector"),
      sub_sector: Map.get(security, "subSector"),
      symbol: Map.get(security, "symbol")
    }
  end
end
