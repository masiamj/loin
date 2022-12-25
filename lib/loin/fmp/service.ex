defmodule Loin.FMP.Service do
  @moduledoc """
  This is the module for communicating with Financial Modeling Prep.
  """
  alias Loin.FMP.Transforms

  @api_base_url "https://financialmodelingprep.com/api/v3/"

  def all_profiles() do
    {:ok, %{data: []}}
  end

  @doc """
  Fetches all securities.
  """
  def all_securities() do
    data =
      "/stock/list"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> Transforms.map(&Transforms.security/1)

    {:ok, %{data: data}}
  end

  @doc """
  Fetches all the peers for all securities.
  """
  def all_securities_peers() do
    {:ok, %{data: []}}
  end

  @doc """
  Batch fetches historical prices for a list of securities.
  """
  def batch_historical_prices(symbols) when is_list(symbols) do
    {:ok,
     %{
       symbols: symbols,
       data: []
     }}
  end

  @doc """
  Fetches all Dow Jones constituents.
  """
  def dow_jones_companies() do
    data = "/dowjones_constituent"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> Transforms.map(&Transforms.well_defined_constituent/1)

    {:ok, %{data: data}}
  end

  @doc """
  Fetches all the ETFs with exposure to a specific asset.
  """
  def etf_exposure_by_stock(symbol) when is_binary(symbol) do
    data = "/etf-stock-exposure/#{symbol}"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> Transforms.map(&Transforms.etf_exposure/1)

    {:ok,
     %{
       symbol: symbol,
       data: data
     }}
  end

  @doc """
  Fetches the holdings of a specific ETF.
  """
  def etf_holdings(symbol) when is_binary(symbol) do
    data = "/etf-holder/#{symbol}"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> Transforms.map(&Transforms.etf_holding/1)

    {:ok,
     %{
       symbol: symbol,
       data: data
     }}
  end

  @doc """
  Fetches the sector exposures of an ETF.
  """
  def etf_sector_weights(symbol) when is_binary(symbol) do
    data = "/etf-sector-weightings/#{symbol}"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> Transforms.map(&Transforms.etf_sector_weight/1)

    {:ok,
     %{
       symbol: symbol,
       data: data
     }}
  end

  @doc """
  Fetches a list of Nasdaq constituents.
  """
  def nasdaq_companies() do
    data = "/nasdaq_constituent"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> Transforms.map(&Transforms.well_defined_constituent/1)

    {:ok, %{data: data}}
  end

  @doc """
  Fetches a list of S&P 500 constituents.
  """
  def sp500_companies() do
    data = "/sp500_constituent"
      |> create_request()
      |> Req.get!()
      |> handle_response()
      |> Transforms.map(&Transforms.well_defined_constituent/1)

    {:ok, %{data: data}}
  end

  # Private helpers

  defp create_request(path, params \\ %{}) do
    params = Map.put(params, "apikey", Loin.Config.fmp_api_key())
    Req.new(base_url: @api_base_url, url: path, params: params)
  end

  defp handle_response(%Req.Response{status: status, body: body}) do
    cond do
      status in [200] -> body
      status in [400, 401, 403, 404, 500] -> {:error, Map.get(body, "error")}
    end
  end
end
