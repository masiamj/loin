defmodule Loin.Workers.TTMRatiosPrimer do
  @moduledoc """
  Primes ttm_ratios in the database.
  """
  use Oban.Worker, queue: :default, max_attempts: 2

  require Logger

  @impl true
  def perform(%Oban.Job{id: id}) do
    Logger.info("Starting TTMRatiosPrimer job: #{id}")
    :ok = Loin.FMP.TTMRatios.process_all()
    Logger.info("Finished TTMRatiosPrimer job: #{id}")

    :ok
  end

  @impl true
  def timeout(_job), do: :timer.minutes(15)
end
