defmodule Loin.FMP.Profiles do
  @moduledoc """
  Utility functions around fmp_securities (profiles).
  """

  require Logger

  import Ecto.Query, warn: false
  alias Loin.Repo
  alias Loin.FMP.{FMPSecurity, Service}

  @doc """
  Inserts all fmp_securities into the table (a priming function).
  """
  def process_all() do
    process_many(20_000)
  end

  @doc """
  Inserts many fmp_securities into the table (a priming function).
  """
  def process_many(limit) when is_integer(limit) do
    Service.all_profiles_stream()
    |> Stream.take(limit)
    |> Stream.chunk_every(10)
    |> Stream.each(fn entries ->
      symbols = Enum.map_join(entries, ", ", &Map.get(&1, :symbol))
      Logger.info("Inserting profiles for symbols: #{symbols}")

      {num_affected, nil} =
        Repo.insert_all(FMPSecurity, entries,
          on_conflict:
            {:replace_all_except,
             [
               :change,
               :change_percent,
               :eps,
               :id,
               :inserted_at,
               :market_cap,
               :pe,
               :price,
               :symbol,
               :volume,
               :volume_avg
             ]},
          conflict_target: [:symbol]
        )

      {:ok, num_affected}
    end)
    |> Stream.run()
  end
end
