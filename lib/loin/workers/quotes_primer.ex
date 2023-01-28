defmodule Loin.Workers.QuotesPrimer do
  @moduledoc """
  Primes quotes in the database (part of fmp_security).
  """
  use Oban.Worker, queue: :default, max_attempts: 2

  require Logger

  @impl true
  def perform(%Oban.Job{id: id}) do
    Logger.info("Starting QuotesPrimer job: #{id}")
    :ok = Loin.FMP.Quotes.process_all()
    Logger.info("Finished QuotesPrimer job: #{id}")

    :ok
  end

  @impl true
  def timeout(_job), do: :timer.minutes(5)
end
