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
  Maps a list of historical price items into the proper application-level structure.
  """
  def historical_prices(historical_items)
      when is_list(historical_items) do
    historical_items
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
      ceo: Map.get(security, "CEO"),
      change: Map.get(security, "Changes") |> maybe_string_to_float(),
      cik: Map.get(security, "cik"),
      city: Map.get(security, "city"),
      country: Map.get(security, "country"),
      currency: Map.get(security, "currency"),
      description: Map.get(security, "description"),
      exchange: Map.get(security, "exchange"),
      exchange_short_name: Map.get(security, "exchangeShortName"),
      full_time_employees: Map.get(security, "fullTimeEmployees") |> maybe_string_to_integer(),
      image: Map.get(security, "image"),
      industry: Map.get(security, "industry"),
      ipo_date: Map.get(security, "ipoDate"),
      is_etf: Map.get(security, "isEtf") == "TRUE",
      last_dividend: Map.get(security, "lastDiv"),
      market_cap: Map.get(security, "MktCap") |> maybe_string_to_integer(),
      name: Map.get(security, "companyName"),
      price: Map.get(security, "Price") |> maybe_string_to_float(),
      sector: Map.get(security, "sector"),
      state: Map.get(security, "state"),
      symbol: symbol,
      volume_avg: Map.get(security, "volAvg"),
      website: Map.get(security, "website")
    }
    |> put_timestamps()
  end

  @doc """
  Adds timestamps on an object (normally used for batch insertion).
  """
  def put_timestamps(item) when is_map(item) do
    Map.merge(item, %{
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    })
  end

  @doc """
  Optionally parses a numeric binary into it's proper numeric form.
  """
  def maybe_string_to_float(value) do
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
      end
    rescue
      ArgumentError ->
        Logger.error("Failed to parse binary value into float", value: value)
        nil
    end
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
