defmodule Mix.Tasks.Loin.Seed.Search do
  @moduledoc "This task seeds the client-side search file."
  require Logger

  use Mix.Task

  @doc """
  Seeds the profiles into a file.
  """
  def run(_args) do
    Mix.Task.run("app.start")

    profiles =
      Loin.FMP.Service.all_profiles_stream()
      |> Stream.map(fn item ->
        Logger.info("Processing #{item.symbol}")
        Map.take(item, [:image, :industry, :market_cap, :name, :sector, :symbol])
      end)
      |> Enum.to_list()
      |> Jason.encode!()

    File.write("./assets/js/hooks/StockSearcher/stock-profiles.json", profiles, [:binary])
  end
end
