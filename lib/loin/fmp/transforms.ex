defmodule Loin.FMP.Transforms do
  @moduledoc """
  Defines common data cleaners and transforms for raw FMP data.
  """

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
