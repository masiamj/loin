defmodule Loin.FMP.WellDefinedConstituents do
  @moduledoc """
  Utility functions around well-defined constituents for specific indices.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Loin.Repo
  alias Loin.FMP.{Service, SecurityWithPerformance}

  @doc """
  Inserts all Dow Jones constituents into the table.
  """
  def dow_jones() do
    Service.dow_jones_constituents()
    |> Stream.chunk_every(10)
    |> Stream.each(fn entries ->
      symbols = Enum.map_join(entries, ", ", &Map.get(&1, :symbol))
      Logger.info("Inserting Dow Jones constituents into table for symbols: #{symbols}")

      {num_affected, nil} =
        Repo.insert_all(SecurityWithPerformance, entries,
          on_conflict: {:replace_all_except, [:symbol]},
          conflict_target: [:symbol]
        )

      {:ok, num_affected}
    end)
    |> Stream.run()
  end

  @doc """
  Inserts all Nasdaq constituents into the table.
  """
  def nasdaq() do
    Service.nasdaq_constituents()
    |> Stream.chunk_every(10)
    |> Stream.each(fn entries ->
      symbols = Enum.map_join(entries, ", ", &Map.get(&1, :symbol))
      Logger.info("Inserting Nasdaq constituents into table for symbols: #{symbols}")

      {num_affected, nil} =
        Repo.insert_all(SecurityWithPerformance, entries,
          on_conflict: {:replace_all_except, [:symbol]},
          conflict_target: [:symbol]
        )

      {:ok, num_affected}
    end)
    |> Stream.run()
  end

  @doc """
  Inserts all Dow Jones constituents into the table.
  """
  def sp500() do
    Service.sp500_constituents()
    |> Stream.chunk_every(10)
    |> Stream.each(fn entries ->
      symbols = Enum.map_join(entries, ", ", &Map.get(&1, :symbol))
      Logger.info("Inserting S&P 500 constituents into table for symbols: #{symbols}")

      {num_affected, nil} =
        Repo.insert_all(SecurityWithPerformance, entries,
          on_conflict: {:replace_all_except, [:symbol]},
          conflict_target: [:symbol]
        )

      {:ok, num_affected}
    end)
    |> Stream.run()
  end
end
