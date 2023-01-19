defmodule Loin.Workers.FMPSecurityPrimer do
  @moduledoc """
  Primes fmp_securities in the database.
  """
  use Oban.Worker, queue: :default, max_attempts: 2

  require Logger

  @impl true
  def perform(%Oban.Job{args: %{"id" => id}}) do
    Logger.info("Starting FMPSecurityPrimer job: #{id}")
    :ok = Loin.FMP.insert_all_profiles()
    Logger.info("Finished FMPSecurityPrimer job: #{id}")

    :ok
  end
end
