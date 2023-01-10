defmodule Loin.FMP.Trends do
  @moduledoc """
  Performs operations for trends.
  """

  def get_many(symbols \\ []) when is_list(symbols) do
    entries = symbols
    |> Enum.uniq()
    |> Enum.chunk_every(5)
    |> Task.async_stream(fn chunk -> Service.batch_historical_prices(chunk) end,
      max_concurrency: 3,
      ordered: true
    )
    |> Stream.flat_map(fn {:ok, result_map} -> result_map end)
    |> Stream.map(fn {symbol, data} -> {symbol, data} end)
    |> Enum.to_list()

  end
end
