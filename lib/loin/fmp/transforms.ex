defmodule Loin.FMP.Transforms do
  @moduledoc """
  Defines common data cleaners and transforms for raw FMP data.
  """
  require Logger

  @automatically_allowed_stocks ["BRK-A", "BRK-B"]

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
        close: Map.get(item, "close") |> string_to_number(:float),
        date: Map.get(item, "date"),
        volume: Map.get(item, "volume") |> string_to_number(:float)
      }
    end)
    |> Enum.reverse()
  end

  @doc """
  Picks out if the stock market is open.
  """
  def is_the_market_open(results) do
    %{
      is_the_us_market_open: Map.get(results, "isTheStockMarketOpen")
    }
  end

  @doc """
  Maps a raw peers entry to an application-level peers entry.
  """
  def peers(security) when is_map(security) do
    Map.get(security, "peersList", [])
  end

  @doc """
  Maps a raw price change entry to an application-level price change entry.
  """
  def price_change(security) when is_map(security) do
    %{
      symbol: Map.get(security, "symbol"),
      day_1_performance: Map.get(security, "1D") |> string_to_number(:float),
      day_5_performance: Map.get(security, "5D") |> string_to_number(:float),
      month_1_performance: Map.get(security, "1M") |> string_to_number(:float),
      month_3_performance: Map.get(security, "3M") |> string_to_number(:float),
      month_6_performance: Map.get(security, "6M") |> string_to_number(:float),
      ytd_performance: Map.get(security, "ytd") |> string_to_number(:float),
      year_1_performance: Map.get(security, "1Y") |> string_to_number(:float),
      year_3_performance: Map.get(security, "3Y") |> string_to_number(:float),
      year_5_performance: Map.get(security, "5Y") |> string_to_number(:float),
      year_10_performance: Map.get(security, "10Y") |> string_to_number(:float),
      max_performance: Map.get(security, "max") |> string_to_number(:float)
    }
    |> put_timestamps()
  end

  @doc """
  Maps a raw quote entry to an application-level quote entry.
  """
  def quote(security) when is_map(security) do
    %{
      change_price: Map.get(security, "change") |> string_to_number(:float),
      change_percent: Map.get(security, "changesPercentage") |> string_to_number(:float),
      day_200_sma: Map.get(security, "priceAvg200") |> string_to_number(:float),
      day_50_sma: Map.get(security, "priceAvg50") |> string_to_number(:float),
      day_high: Map.get(security, "dayHigh") |> string_to_number(:float),
      day_low: Map.get(security, "dayLow") |> string_to_number(:float),
      eps: Map.get(security, "eps") |> string_to_number(:float),
      market_cap: Map.get(security, "marketCap") |> string_to_number(:integer),
      open: Map.get(security, "open") |> string_to_number(:float),
      pe: Map.get(security, "pe") |> string_to_number(:float),
      previous_close: Map.get(security, "previousClose") |> string_to_number(:float),
      price: Map.get(security, "price") |> string_to_number(:float),
      volume: Map.get(security, "volume") |> string_to_number(:integer),
      volume_avg: Map.get(security, "avgVolume") |> string_to_number(:integer),
      year_high: Map.get(security, "yearHigh") |> string_to_number(:float),
      year_low: Map.get(security, "yearLow") |> string_to_number(:float),
      # shares_outstanding: Map.get(security, "sharesOutstanding") |> string_to_number(:integer),
      symbol: Map.get(security, "symbol")
    }
    |> put_timestamps()
  end

  @doc """
  Maps a raw Profile to an application-level security.
  """
  def profile(%{"Symbol" => symbol} = security) when is_map(security) do
    market_cap = Map.get(security, "MktCap") |> string_to_number(:integer)
    raw_is_etf = Map.get(security, "isEtf")

    %{
      ceo: Map.get(security, "CEO"),
      # change: Map.get(security, "Changes") |> string_to_number(:float),
      change_price: Map.get(security, "Changes") |> string_to_number(:float),
      cik: Map.get(security, "cik"),
      city: Map.get(security, "city"),
      country: Map.get(security, "country"),
      currency: Map.get(security, "currency"),
      description: Map.get(security, "description"),
      exchange: Map.get(security, "exchange"),
      exchange_short_name: Map.get(security, "exchangeShortName"),
      full_time_employees: Map.get(security, "fullTimeEmployees") |> string_to_number(:integer),
      image: Map.get(security, "image"),
      industry: Map.get(security, "industry"),
      ipo_date: Map.get(security, "ipoDate"),
      # is_active: is_profile_active(%{symbol: symbol}),
      is_etf: raw_is_etf == "true" || raw_is_etf == true || raw_is_etf == "TRUE",
      last_dividend: Map.get(security, "lastDiv") |> string_to_number(:float),
      market_cap: market_cap,
      name: Map.get(security, "companyName"),
      price: Map.get(security, "Price") |> string_to_number(:float),
      sector: Map.get(security, "sector"),
      state: Map.get(security, "state"),
      symbol: symbol,
      volume_avg: Map.get(security, "volAvg") |> string_to_number(:integer),
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
  Maps a raw TTM Ratio map to an application-level ttm_ratio.
  """
  def ttm_ratio(%{"symbol" => symbol} = item) when is_map(item) do
    pe_ratio = Map.get(item, "peRatioTTM") |> string_to_number(:float)

    earnings_yield =
      case pe_ratio do
        value when is_number(value) and value > 0 -> 1 / pe_ratio
        _ -> nil
      end

    %{
      cash_ratio: Map.get(item, "cashRatioTTM") |> string_to_number(:float),
      current_ratio: Map.get(item, "currentRatioTTM") |> string_to_number(:float),
      dividend_yield: Map.get(item, "dividendYielTTM") |> string_to_number(:float),
      earnings_yield: earnings_yield,
      net_profit_margin: Map.get(item, "netProfitMarginTTM") |> string_to_number(:float),
      pe_ratio: pe_ratio,
      peg_ratio: Map.get(item, "pegRatioTTM") |> string_to_number(:float),
      price_to_book_ratio: Map.get(item, "priceToBookRatioTTM") |> string_to_number(:float),
      price_to_sales_ratio: Map.get(item, "priceToSalesRatioTTM") |> string_to_number(:float),
      quick_ratio: Map.get(item, "quickRatioTTM") |> string_to_number(:float),
      return_on_assets: Map.get(item, "returnOnAssetsTTM") |> string_to_number(:float),
      return_on_equity: Map.get(item, "returnOnEquityTTM") |> string_to_number(:float),
      symbol: symbol
    }
    |> put_timestamps()
  end

  @doc """
  Maps a well-defined ETF constituent into a proper structure.
  """
  def well_defined_constituent(security) when is_map(security) do
    %{
      cik: Map.get(security, "cik"),
      founded: Map.get(security, "founded"),
      headquarters: Map.get(security, "headquarters"),
      name: Map.get(security, "name"),
      sector: Map.get(security, "sector"),
      sub_sector: Map.get(security, "subSector"),
      symbol: Map.get(security, "symbol")
    }
    |> put_timestamps()
  end

  # Private

  defp is_profile_active(%{symbol: symbol}) when symbol in @automatically_allowed_stocks, do: true

  defp is_profile_active(%{symbol: symbol}) when is_binary(symbol) do
    has_dash = String.contains?(symbol, "-")
    has_dot = String.contains?(symbol, ".")
    !has_dash && !has_dot
  end

  defp string_to_number(nil, _any), do: nil
  defp string_to_number("", _any), do: nil
  defp string_to_number(value, :integer) when is_integer(value), do: value

  defp string_to_number(value, :integer) when is_float(value), do: trunc(value)

  defp string_to_number(value, :integer) do
    case Integer.parse(value) do
      {int, ""} -> int
      {int, _dec} -> int
      _ -> nil
    end
  end

  defp string_to_number(value, :float) when is_float(value), do: value
  defp string_to_number(value, :float) when is_integer(value), do: value + 0.0

  defp string_to_number(value, :float) do
    case Float.parse(value) do
      {float, ""} -> float
      {float, _dec} -> float
      _ -> nil
    end
  end
end
