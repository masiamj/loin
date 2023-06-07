defmodule Loin.FMP.Trends do
  @moduledoc """
  Performs operations for trends.
  """
  require Logger
  alias Loin.Repo
  alias Loin.FMP.{DailyTrend, SecurityWithPerformance, Service, Transforms}
  import Ecto.Query, warn: false

  @doc """
  Processes trends for all available symbols.
  """
  def process_all() do
    Logger.info("Starting to process all trends...")

    Repo.transaction(
      fn ->
        from(s in SecurityWithPerformance,
          where:
            (not like(s.symbol, "%.%") and not like(s.symbol, "%-%") and
               fragment("LENGTH(?)", s.symbol) < 7) or
              s.symbol in ["BRK-A", "BRK-B"],
          select: s.symbol,
          order_by: [asc: s.symbol]
        )
        |> Repo.stream()
        |> Stream.chunk_every(5)
        |> Task.async_stream(
          fn symbols ->
            {:ok, processed_symbols} = fetch_and_store(symbols)
            Logger.info("Processed trends for #{Enum.join(processed_symbols, ", ")}")
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
        |> Stream.chunk_every(5)
        |> Task.async_stream(
          fn items ->
            {:ok, processed_symbols} = fetch_and_store(items)
            Logger.info("Processed trends for #{Enum.join(processed_symbols, ", ")}")
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

  @doc """
  Prunes DailyTrend from a certain number of days ago.
  """
  def prune_many(days_ago \\ 5) do
    {num_affected, nil} =
      from(dt in DailyTrend,
        where: dt.updated_at < from_now(^days_ago, "day")
      )
      |> Repo.delete_all()

    {:ok, num_affected}
  end

  ####################
  # Private
  ####################

  defp compute_recent_high_prices(data) do
    Task.await_many([
      Task.async(fn -> Enum.take(data, -20) |> maximum_by_close_extract_close() end),
      Task.async(fn -> Enum.take(data, -50) |> maximum_by_close_extract_close() end),
      Task.async(fn -> Enum.take(data, -100) |> maximum_by_close_extract_close() end)
    ])
  end

  defp extract_latest_trend({_symbol, []}), do: nil

  defp extract_latest_trend({symbol, data}) when is_list(data) do
    [day_20_high, day_50_high, day_100_high] = compute_recent_high_prices(data)

    last_item =
      data
      |> List.last(%{})
      |> Map.put(:symbol, symbol)
      |> Map.update!(:date, &Date.from_iso8601!/1)
      |> Transforms.put_timestamps()

    last_close = Map.get(last_item, :close, 0)

    Map.merge(last_item, %{
      near_day_20_high: last_close > 0.9 * day_20_high,
      near_day_50_high: last_close > 0.9 * day_50_high,
      near_day_100_high: last_close > 0.9 * day_100_high
    })
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

  defp maximum_by_close_extract_close(data) when is_list(data) do
    data
    |> Enum.max_by(&Map.get(&1, :close))
    |> Map.get(:close)
  end
end
