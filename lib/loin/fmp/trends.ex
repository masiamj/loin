defmodule Loin.FMP.Trends do
  @moduledoc """
  Performs operations for trends.
  """
  alias Loin.Repo
  alias Loin.FMP.{DailyTrend, FMPSecurity, Service, Transforms}
  import Ecto.Query, warn: false

  @doc """
  Processes trends for all available symbols.
  """
  def process_all() do
    Repo.transaction(
      fn ->
        FMPSecurity
        |> select([:symbol])
        |> order_by(asc: :symbol)
        |> Repo.stream()
        |> Stream.chunk_every(5)
        |> Task.async_stream(
          fn items ->
            symbols = Enum.map(items, &Map.get(&1, :symbol))
            {:ok, processed_symbols} = fetch_and_store(symbols)
            processed_symbols
          end,
          max_concurrency: 2,
          ordered: true
        )
        |> Stream.run()
      end,
      timeout: :infinity
    )
  end

  @doc """
  Given a list of symbols, processes trends for all available symbols.
  """
  def process_many(symbols) when is_list(symbols) do
    Repo.transaction(
      fn ->
        symbols
        |> Stream.chunk_every(5)
        |> Task.async_stream(
          fn items ->
            {:ok, processed_symbols} = fetch_and_store(items)
            processed_symbols
          end,
          max_concurrency: 2,
          ordered: true
        )
        |> Stream.run()
      end,
      timeout: :infinity
    )
  end

  defp extract_latest_trend({_symbol, []}), do: nil

  defp extract_latest_trend({symbol, data}) when is_list(data) do
    data
    |> List.last(%{})
    |> Map.put(:symbol, symbol)
    |> Map.update!(:date, &Date.from_iso8601!/1)
    |> Transforms.put_timestamps()
  end

  defp fetch_and_store(symbols) when is_list(symbols) do
    {:ok, _number_of_rows_affected} =
      symbols
      |> Service.batch_historical_prices()
      |> Enum.map(&extract_latest_trend/1)
      |> Enum.filter(&is_map/1)
      |> insert_many_daily_trends()

    {:ok, symbols}
  end

  defp insert_many_daily_trends(entries) when is_list(entries) do
    {num_affected, nil} =
      Repo.insert_all(DailyTrend, entries,
        on_conflict: {:replace_all_except, [:id, :date, :inserted_at, :symbol]},
        conflict_target: [:symbol, :date]
      )

    {:ok, num_affected}
  end
end
