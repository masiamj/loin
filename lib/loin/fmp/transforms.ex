defmodule Loin.FMP.Transforms do
  @moduledoc """
  Defines common data cleaners and transforms for raw FMP data.
  """
  require Logger

  @doc """
  Transforms a FMP ETF stock exposure to an application-level security.
  """
  def etf_exposure(security) when is_map(security) do
    %{
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
  def historical_prices(%{"historical" => historical})
      when is_list(historical) do
    historical
    |> Enum.map(fn item ->
      %{
        close: Map.get(item, "close"),
        date: Map.get(item, "date"),
        volume: Map.get(item, "volume")
      }
    end)
    |> Enum.reverse()
  end

  @doc """
  Maps a raw peers entry to an application-level peers entry.
  """
  def peers(security) when is_map(security) do
    Map.get(security, "peersList", [])
  end

  @doc """
  Maps a raw Profile to an application-level security.
  """
  def profile(%{"Symbol" => symbol} = security) when is_map(security) do
    %{
      country: Map.get(security, "country"),
      currency: Map.get(security, "currency"),
      description: Map.get(security, "description"),
      exchange: Map.get(security, "exchange"),
      exchange_short_name: Map.get(security, "exchangeShortName"),
      full_time_employees: Map.get(security, "fullTimeEmployees") |> maybe_string_to_integer(),
      image: Map.get(security, "image"),
      industry: Map.get(security, "industry"),
      is_etf: Map.get(security, "isEtf") == "TRUE",
      market_cap: Map.get(security, "MktCap") |> maybe_string_to_integer(),
      name: Map.get(security, "companyName"),
      sector: Map.get(security, "sector"),
      symbol: symbol,
      website: Map.get(security, "website")
    }
    |> put_timestamps()
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

  defp put_timestamps(item) when is_map(item) do
    Map.merge(item, %{
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    })
  end

  @doc """
  Optionally parses a numeric binary into it's proper numeric form.
  """
  def maybe_string_to_integer(value) do
    try do
      cond do
        is_nil(value) ->
          nil

        value == "" ->
          nil

        true ->
          value
          |> Float.parse()
          |> elem(0)
          |> trunc()
      end
    rescue
      ArgumentError ->
        Logger.error("Failed to parse binary value into integer", value: value)
        nil
    end
  end
end
