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

    "/historical-price-full/#{joined_symbols}"
    |> create_request()
    |> Req.get!()
    |> handle_response()
    |> handle_historical_data_response()
    |> Utils.map(fn {symbol, data} -> {symbol, Transforms.historical_prices(data)} end)
    |> Utils.map(fn {symbol, data} -> {symbol, Utils.create_indicators(data)} end)
    |> Enum.into(%{})
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
