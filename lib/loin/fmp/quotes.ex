defmodule Loin.FMP.Quotes do
  @moduledoc """
  Performs operations for quotes.
  """
  require Logger
  alias Loin.Repo
  alias Loin.FMP.{FMPSecurity, Service}
  import Ecto.Query, warn: false

  @doc """
  Processes trends for all available symbols.
  """
  def process_all() do
    Logger.info("Starting to process all trends...")

    Repo.transaction(
      fn ->
        FMPSecurity
        |> select([:symbol])
        |> order_by(asc: :symbol)
        |> Repo.stream()
        |> Stream.chunk_every(10)
        |> Task.async_stream(
          fn items ->
            symbols = Enum.map(items, &Map.get(&1, :symbol))
            {:ok, processed_symbols} = fetch_and_store(symbols)
            Logger.info("Processed quotes for #{Enum.join(processed_symbols, ", ")}")
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

  @doc """
  Given a list of symbols, processes trends for all available symbols.
  """
  def process_many(symbols) when is_list(symbols) do
    Logger.info("Starting to process many trends...")

    Repo.transaction(
      fn ->
        symbols
        |> Stream.chunk_every(10)
        |> Task.async_stream(
          fn items ->
            {:ok, processed_symbols} = fetch_and_store(items)
            Logger.info("Processed quotes for #{Enum.join(processed_symbols, ", ")}")
            processed_symbols
          end,
          max_concurrency: 2,
          ordered: true
        )
        |> Stream.run()
      end,
      timeout: :infinity
    )

    {:ok, symbols}
  end

  defp fetch_and_store(symbols) when is_list(symbols) do
    {:ok, _number_of_rows_affected} =
      symbols
      |> Service.batch_quotes()
      |> Map.values()
      |> insert_many_quotes()

    {:ok, symbols}
  end

  defp insert_many_quotes(entries) when is_list(entries) do
    {num_affected, nil} =
      Repo.insert_all(FMPSecurity, entries,
        on_conflict:
          {:replace,
           [:change, :change_percent, :eps, :market_cap, :pe, :price, :volume, :volume_avg, :updated_at]},
        conflict_target: [:symbol]
      )

    {:ok, num_affected}
  end
end
