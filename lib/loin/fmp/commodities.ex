defmodule Loin.FMP.Commodities do
  @moduledoc """
  Utility functions around Commodities quotes.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Loin.Repo
  alias Loin.FMP.{SecurityWithPerformance, Service}

  @doc """
  Inserts many Commodities securities into a table (priming).
  """
  def process_many(limit \\ 100_000) when is_integer(limit) do
    Service.commodities_quotes()
    |> Enum.chunk_every(10)
    |> Enum.each(fn entries ->
      symbols = Enum.map_join(entries, ", ", &Map.get(&1, :symbol))
      Logger.info("Inserting commodities quotes for symbols: #{symbols}")

      {num_affected, nil} =
        Repo.insert_all(SecurityWithPerformance, entries,
          on_conflict:
            {:replace,
             [
               :change_price,
               :change_percent,
               :day_200_sma,
               :day_50_sma,
               :day_high,
               :day_low,
               :eps,
               :exchange,
               :market_cap,
               :name,
               :open,
               :pe,
               :previous_close,
               :price,
               :shares_outstanding,
               :volume,
               :volume_avg,
               :year_high,
               :year_low
             ]},
          conflict_target: [:symbol]
        )

      {:ok, num_affected}
    end)
  end
end
