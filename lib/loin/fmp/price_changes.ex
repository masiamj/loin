defmodule Loin.FMP.PriceChanges do
  @moduledoc """
  Performs operations for quotes.
  """
  require Logger
  alias Loin.Repo
  alias Loin.FMP.{SecurityWithPerformance, Service}
  import Ecto.Query, warn: false

  @doc """
  Processes trends for all available symbols.
  """
  def process_all() do
    Logger.info("Starting to process all price changes...")

    Repo.transaction(
      fn ->
        SecurityWithPerformance
        |> select([:symbol])
        |> order_by(asc: :symbol)
        |> Repo.stream()
        |> Stream.chunk_every(10)
        |> Task.async_stream(
          fn items ->
            symbols = Enum.map(items, &Map.get(&1, :symbol))
            {:ok, processed_symbols} = fetch_and_store(symbols)
            Logger.info("Processed price changes for #{Enum.join(processed_symbols, ", ")}")
            processed_symbols
          end,
          max_concurrency: 2,
          ordered: true
        )
        |> Stream.run()
      end,
      timeout: :infinity
    )

    :ok
  end

  defp fetch_and_store(symbols) when is_list(symbols) do
    {:ok, _number_of_rows_affected} =
      symbols
      |> Service.batch_price_changes()
      |> Map.values()
      |> insert_many_price_changes()

    {:ok, symbols}
  end

  defp insert_many_price_changes(entries) when is_list(entries) do
    {num_affected, nil} =
      Repo.insert_all(SecurityWithPerformance, entries,
        on_conflict:
          {:replace,
           [
             :day_1_performance,
             :day_5_performance,
             :month_1_performance,
             :month_3_performance,
             :month_6_performance,
             :updated_at,
             :ytd_performance,
             :year_1_performance,
             :year_3_performance,
             :year_5_performance,
             :year_10_performance,
             :max_performance
           ]},
        conflict_target: [:symbol]
      )

    {:ok, num_affected}
  end
end
