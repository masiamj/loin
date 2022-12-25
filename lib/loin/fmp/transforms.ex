defmodule Loin.FMP.Transforms do
  @moduledoc """
  Defines common data cleaners and transforms for raw FMP data.
  """


  @doc """
  Transforms a FMP ETF stock exposure to an application-level security.
  """
  def etf_exposure(security) when is_map(security) do
    %{
      asset_symbol: Map.get(security, "assetExposure"),
      etf_symbol: Map.get(security, "etfSymbol"),
      etf_weight_percentage: Map.get(security, "weightPercentage"),
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
  Transforms a FMP ETF constituent to an application-level security for the well-known
  indices (S&P 500, Nasdaq, Dow Jones).
  """
  def well_defined_constituent(security) when is_map(security) do
    %{
      name: Map.get(security, "name"),
      sector: Map.get(security, "sector"),
      sub_sector: Map.get(security, "subSector"),
      symbol: Map.get(security, "symbol"),
    }
  end

  @doc """
  Maps a list of items with a transform in a concurrent way
  """
  def map(items, transform) when is_list(items) do
    items
    |> Flow.from_enumerable()
    |> Flow.partition()
    |> Flow.map(fn item -> transform.(item) end)
    |> Enum.to_list()
  end

  @doc """
  Transforms a FMP security to an application-level security.
  """
  def security(security) when is_map(security) do
    %{
      exchange: Map.get(security, "exchange"),
      exchange_short_name: Map.get(security, "exchangeShortName"),
      name: Map.get(security, "name"),
      symbol: Map.get(security, "symbol"),
      type: Map.get(security, "type")
    }
  end
end
