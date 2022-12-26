defmodule Loin.FMPFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Loin.FMP` context.
  """

  @doc """
  Generate a fmp_security.
  """
  def fmp_security_fixture(attrs \\ %{}) do
    {:ok, fmp_security} =
      attrs
      |> Enum.into(%{
        description: "some description",
        exchange: "some exchange",
        exchange_short_name: "some exchange_short_name",
        full_time_employees: 42,
        image: "some image",
        in_dow_jones: true,
        in_nasdaq: true,
        in_sp500: true,
        industry: "some industry",
        is_etf: true,
        market_cap: 42,
        name: "some name",
        sector: "some sector",
        symbol: "some symbol",
        website: "some website"
      })
      |> Loin.FMP.create_fmp_security()

    fmp_security
  end
end
