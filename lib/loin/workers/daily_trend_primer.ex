defmodule Loin.Workers.DailyTrendPrimer do
  @moduledoc """
  Primes daily_trends in the database.
  """
  use Oban.Worker, queue: :default, max_attempts: 2

  require Logger

  @impl true
  def perform(%Oban.Job{args: %{"id" => id}}) do
    Logger.info("Starting DailyTrendPrimer job: #{id}")
    :ok = Loin.FMP.Trends.process_all()
    Logger.info("Finished DailyTrendPrimer job: #{id}")

    :ok
  end
end
