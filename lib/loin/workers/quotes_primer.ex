defmodule Loin.Workers.QuotesPrimer do
  @moduledoc """
  Primes quotes in the database (part of fmp_security).
  """
  use Oban.Worker, queue: :default, max_attempts: 2

  require Logger

  @impl true
  def perform(%Oban.Job{args: %{"id" => id}}) do
    Logger.info("Starting QuotesPrimer job: #{id}")
    # :ok = Loin.FMP.insert_all_profiles()
    Logger.info("Finished QuotesPrimer job: #{id}")

    :ok
  end
end
