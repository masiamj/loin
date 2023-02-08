defmodule Loin.FMP.TTMRatios do
  @moduledoc """
  Utility functions around ttm_ratios.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Loin.Repo
  alias Loin.FMP.{Service, TTMRatio}

  @doc """
  Inserts all ttm_ratios into the table (a priming function).
  """
  def process_all() do
    process_many(50_000)
  end

  @doc """
  Inserts many ttm_ratios into the table (a priming function).
  """
  def process_many(limit) when is_integer(limit) do
    Service.all_ttm_ratios()
    |> Stream.take(limit)
    |> Stream.chunk_every(10)
    |> Stream.each(fn entries ->
      symbols = Enum.map_join(entries, ", ", &Map.get(&1, :symbol))
      Logger.info("Inserting ttm_ratios for symbols: #{symbols}")

      {num_affected, nil} =
        Repo.insert_all(TTMRatio, entries,
          on_conflict: {:replace_all_except, [:symbol]},
          conflict_target: [:symbol]
        )

      {:ok, num_affected}
    end)
    |> Stream.run()
  end
end
