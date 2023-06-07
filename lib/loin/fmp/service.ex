defmodule Loin.FMP.Service do
  @moduledoc """
  This is the module for communicating with Financial Modeling Prep.
  """
  require Logger
  alias Loin.FMP.{Transforms, Utils}

  @api_base_url "https://financialmodelingprep.com/api/v3/"
  @bulk_api_base_url "https://financialmodelingprep.com/api/v4/"

  @doc """
  Fetches all the profiles for all securities (Stream).
  """
  def all_profiles_stream() do
    Logger.info("Starting all profiles stream...")

    (@bulk_api_base_url <> "profile/all" <> "?apikey=#{Loin.Config.fmp_api_key()}")
    |> RemoteFileStreamer.stream()
    |> CSV.decode!(escape_max_lines: 25, headers: true)
    # |> Stream.filter(&Utils.is_us_security/1)
    |> Stream.map(&Transforms.profile/1)
  end

  @doc """
  Fetches all the Ratios TTM for all securities (Stream).
  """
  def all_ttm_ratios() do
    Logger.info("Starting all Ratios TTM stream...")

    (@bulk_api_base_url <> "ratios-ttm-bulk" <> "?apikey=#{Loin.Config.fmp_api_key()}")
    |> RemoteFileStreamer.stream()
    |> CSV.decode!(escape_max_lines: 25, headers: true)
    |> Stream.filter(&Utils.is_valid_ttm_ratio/1)
    |> Stream.map(&Transforms.ttm_ratio/1)
  end

  @doc """
  Batch fetches historical prices for a list of securities.
  """
  def batch_historical_prices(symbols) when is_list(symbols) do
    joined_symbols = Enum.join(symbols, ",")
    Logger.info("Batch requesting historical data for #{joined_symbols}")

    result =
      "/historical-price-full/#{joined_symbols}"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> handle_historical_data_response()
      |> Utils.map(fn {symbol, data} -> {symbol, Transforms.historical_prices(data)} end)
      |> Utils.map(fn {symbol, data} -> {symbol, Utils.create_indicators(data)} end)
      |> Enum.into(%{})

    Logger.info(
      "Got batch historical data result map for symbols #{Map.keys(result) |> Enum.join(", ")}"
    )

    result
  end

  @doc """
  Fetches the constituents of the Dow Jones
  """
  def dow_jones_constituents() do
    Logger.info("Requesting Dow Jones constituents")

    "/dowjones_constituent"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.well_defined_constituent/1)
  end

  @doc """
  Fetches all the ETFs with exposure to a specific asset.
  """
  def etf_exposure_by_stock(symbol) when is_binary(symbol) do
    Logger.info("Requesting ETF exposure for symbol #{symbol}")

    "/etf-stock-exposure/#{symbol}"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.etf_exposure/1)
  end

  @doc """
  Fetches the holdings of a specific ETF.
  """
  def etf_holdings(symbol) when is_binary(symbol) do
    Logger.info("Requesting ETF holdings for symbol #{symbol}")

    "/etf-holder/#{symbol}"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.etf_holding/1)
  end

  @doc """
  Fetches the sector exposures of an ETF.
  """
  def etf_sector_weights(symbol) when is_binary(symbol) do
    Logger.info("Requesting ETF sector exposure for symbol #{symbol}")

    "/etf-sector-weightings/#{symbol}"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.etf_sector_weight/1)
  end

  @doc """
  Fetches the constituents of the Nasdaq
  """
  def nasdaq_constituents() do
    Logger.info("Requesting Nasdaq constituents")

    "/nasdaq_constituent"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.well_defined_constituent/1)
  end

  @doc """
  Fetches whether the stock market is open.
  """
  def market_status() do
    Logger.info("Requesting Market status")

    "/is-the-market-open"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Transforms.is_the_market_open()
  end

  @doc """
  Fetches the peers of a stock.
  """
  def peers(symbol) when is_binary(symbol) do
    Logger.info("Requesting peers for symbol #{symbol}")

    "/stock_peers"
    |> create_request_v4(%{symbol: symbol})
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.peers/1)
    |> List.flatten()
  end

  def batch_quotes(symbols) when is_list(symbols) do
    joined_symbols = Enum.map_join(symbols, ",", &String.upcase/1)
    Logger.info("Batch requesting quotes for #{joined_symbols}")

    result =
      "/quote/#{joined_symbols}"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> Utils.map(&Transforms.quote/1)
      |> Enum.into(%{}, fn %{symbol: symbol} = item -> {symbol, item} end)

    Logger.info("Got batch quotes result map for symbols #{Map.keys(result) |> Enum.join(", ")}")

    result
  end

  def batch_price_changes(symbols) when is_list(symbols) do
    joined_symbols = Enum.map_join(symbols, ",", &String.upcase/1)
    Logger.info("Batch requesting price changes for #{joined_symbols}")

    result =
      "/stock-price-change/#{joined_symbols}"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> Utils.map(&Transforms.price_change/1)
      |> Enum.into(%{}, fn %{symbol: symbol} = item -> {symbol, item} end)

    Logger.info(
      "Got batch stock price change result map for symbols #{Map.keys(result) |> Enum.join(", ")}"
    )

    result
  end

  @doc """
  Fetches the constituents of the S&P 500
  """
  def sp500_constituents() do
    Logger.info("Requesting S&P 500 constituents")

    "/sp500_constituent"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.well_defined_constituent/1)
  end

  # Private

  defp create_request(path, params \\ %{}) do
    params = Map.put(params, "apikey", Loin.Config.fmp_api_key())
    Req.new(base_url: @api_base_url, url: path, params: params)
  end

  defp create_request_v4(path, params) do
    params = Map.put(params, "apikey", Loin.Config.fmp_api_key())
    Req.new(base_url: @bulk_api_base_url, url: path, params: params)
  end

  defp handle_response(%Req.Response{status: status, body: body} = response) do
    cond do
      status in [200] ->
        body

      status in [400, 401, 403, 404, 500] ->
        Logger.error("Failed request to FMP: #{response}")
        {:error, Map.get(body, "error")}
    end
  end

  defp handle_historical_data_response(response) do
    case response do
      %{"historical" => historical, "symbol" => symbol} ->
        Map.put(%{}, symbol, historical)

      %{"historicalStockList" => stock_list} ->
        Enum.into(stock_list, %{}, fn %{"historical" => historical, "symbol" => symbol} ->
          {symbol, historical}
        end)

      %{} ->
        %{}
    end
  end
end
