defmodule Loin.FMP.Service do
  @moduledoc """
  This is the module for communicating with Financial Modeling Prep.
  """
  alias Loin.FMP.Transforms

  @api_base_url "https://financialmodelingprep.com/api/v3/"
  @api_key "586925300eff8f1e03fc0631405ce2e0"

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

  def all_securities_peers() do
    {:ok, %{data: []}}
  end

  def batch_historical_prices(symbols) when is_list(symbols) do
    {:ok,
     %{
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

  # Private helpers

  defp create_request(path, params \\ %{}) do
    params = Map.put(params, "apikey", @api_key)
    Req.new(base_url: @api_base_url, url: path, params: params)
  end

  defp handle_response(%Req.Response{status: status, body: body}) do
    cond do
      status in [200] -> body
      status in [400, 401, 403, 404, 500] -> {:error, Map.get(body, "error")}
    end
  end
end
