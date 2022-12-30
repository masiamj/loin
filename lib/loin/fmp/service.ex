defmodule Loin.FMP.Service do
  @moduledoc """
  This is the module for communicating with Financial Modeling Prep.
  """
  alias Loin.FMP.{Transforms, Utils}

  @api_base_url "https://financialmodelingprep.com/api/v3/"
  @bulk_api_base_url "https://financialmodelingprep.com/api/v4/"

  @doc """
  Fetches all the profiles for all securities (Stream).
  """
  def all_profiles_stream() do
    (@bulk_api_base_url <> "/profile/all" <> "?apikey=#{Loin.Config.fmp_api_key()}")
    |> RemoteFileStreamer.stream()
    |> CSV.decode!(escape_max_lines: 25, headers: true)
    |> Stream.filter(&Utils.is_us_security/1)
    |> Stream.map(&Transforms.profile/1)
  end

  @doc """
  Batch fetches historical prices for a list of securities.
  """
  def batch_historical_prices(symbols) when is_list(symbols) do
    joined_symbols = Enum.join(symbols, ",")

    data =
      "/historical-price-full/#{joined_symbols}"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> then(fn response ->
        case response do
          %{"historicalStockList" => historical_stock_list} -> historical_stock_list
          %{"symbol" => _symbol} = item -> [item]
        end
      end)
      |> Utils.map(&Transforms.historical_prices/1)
      |> Utils.map(&Utils.create_indicators/1)

    Enum.zip_reduce([symbols, data], %{}, fn [symbol, data], acc ->
      Map.merge(acc, %{symbol => data})
    end)
  end

  @doc """
  Fetches all Dow Jones constituents.
  """
  def dow_jones_companies() do
    "/dowjones_constituent"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.well_defined_constituent/1)
  end

  @doc """
  Fetches symbols for all Dow Jones companies
  """
  def dow_jones_companies_symbols() do
    dow_jones_companies()
    |> create_set_of_symbols()
  end

  @doc """
  Fetches all the ETFs with exposure to a specific asset.
  """
  def etf_exposure_by_stock(symbol) when is_binary(symbol) do
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
    "/etf-sector-weightings/#{symbol}"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.etf_sector_weight/1)
  end

  @doc """
  Fetches a list of Nasdaq constituents.
  """
  def nasdaq_companies() do
    "/nasdaq_constituent"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.well_defined_constituent/1)
  end

  @doc """
  Fetches symbols for all Nasdaq companies
  """
  def nasdaq_companies_symbols() do
    nasdaq_companies()
    |> create_set_of_symbols()
  end

  @doc """
  Fetches the peers of a stock.
  """
  def peers(symbol) when is_binary(symbol) do
    "/stock_peers"
    |> create_request_v4(%{symbol: symbol})
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.peers/1)
    |> List.flatten()
  end

  @doc """
  Fetches a list of S&P 500 constituents.
  """
  def sp500_companies() do
    "/sp500_constituent"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> Utils.map(&Transforms.well_defined_constituent/1)
  end

  @doc """
  Fetches symbols for all S&P 500 companies
  """
  def sp500_companies_symbols() do
    sp500_companies()
    |> create_set_of_symbols()
  end

  # Private helpers

  defp create_set_of_symbols(companies) when is_list(companies) do
    companies
    |> Enum.map(&Map.get(&1, :symbol))
    |> MapSet.new()
  end

  defp create_request(path, params \\ %{}) do
    params = Map.put(params, "apikey", Loin.Config.fmp_api_key())
    Req.new(base_url: @api_base_url, url: path, params: params)
  end

  defp create_request_v4(path, params) do
    params = Map.put(params, "apikey", Loin.Config.fmp_api_key())
    Req.new(base_url: @bulk_api_base_url, url: path, params: params)
  end

  defp handle_response(%Req.Response{status: status, body: body}) do
    cond do
      status in [200] -> body
      status in [400, 401, 403, 404, 500] -> {:error, Map.get(body, "error")}
    end
  end
end
