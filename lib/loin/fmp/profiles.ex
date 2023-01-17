defmodule Loin.FMP.Profiles do
  @moduledoc """
  Tasks for dealing with profiles.
  """

  require Logger

  @doc """
  Seeds the profiles into a file.
  """
  def seed(limit) when is_integer(limit) do
    profiles =
      Loin.FMP.Service.all_profiles_stream()
      |> Stream.map(fn item ->
        Logger.info("Processing #{item.symbol}")
        Map.take(item, [:image, :industry, :name, :sector, :symbol])
      end)
      |> Enum.take(limit)
      |> Jason.encode!()

    File.write("./assets/js/hooks/StockSearcher/stock-profiles.json", profiles, [:binary])
  end
end
