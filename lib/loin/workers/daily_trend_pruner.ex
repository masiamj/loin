defmodule Loin.Workers.DailyTrendPruner do
  @moduledoc """
  Cleans up old daily_trends storage.
  """
  use Oban.Worker, queue: :default, max_attempts: 2

  require Logger

  @impl true
  def perform(%Oban.Job{args: %{"id" => id}}) do
    Logger.info("Starting DailyTrendPruner job: #{id}")
    {:ok, number_of_trends_removed} = Loin.FMP.Trends.prune_many(5)

    Logger.info(
      "Finished DailyTrendPruner job: #{id}, removed #{number_of_trends_removed} records"
    )

    :ok
  end
end
