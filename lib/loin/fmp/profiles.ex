defmodule Loin.FMP.Profiles do
  @moduledoc """
  Utility functions around fmp_securities (profiles).
  """

  require Logger

  import Ecto.Query, warn: false
  alias Loin.Repo
  alias Loin.FMP.{SecurityWithPerformance, Service}

  @doc """
  Inserts many fmp_securities into the table (a priming function).
  """
  def process_many(limit \\ 100_000) when is_integer(limit) do
    Service.all_profiles_stream()
    |> Stream.take(limit)
    |> Stream.chunk_every(10)
    |> Stream.each(fn entries ->
      symbols = Enum.map_join(entries, ", ", &Map.get(&1, :symbol))
      Logger.info("Inserting profiles for symbols: #{symbols}")

      {num_affected, nil} =
        Repo.insert_all(SecurityWithPerformance, entries,
          on_conflict:
            {:replace,
             [
               :address,
               :beta,
               :ceo,
               :cik,
               :city,
               :country,
               :currency,
               :cusip,
               :dcf,
               :dcf_difference,
               :description,
               :exchange,
               :exchange_short_name,
               :full_time_employees,
               :image,
               :industry,
               :ipo_date,
               :is_adr,
               :is_etf,
               :is_fund,
               :isin,
               :last_dividend,
               :name,
               :sector,
               :state,
               :updated_at,
               :website,
               :zip
             ]},
          conflict_target: [:symbol]
        )

      {:ok, num_affected}
    end)
    |> Stream.run()
  end
end
