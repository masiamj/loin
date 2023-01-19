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
        ceo: "Mr. Elon Musk",
        change: 1.32,
        change_percent: 2.23,
        cik: "323423423",
        city: "Chicago",
        country: "US",
        currency: "USD",
        description: "some description",
        eps: 232.23,
        exchange: "some exchange",
        exchange_short_name: "some exchange_short_name",
        full_time_employees: 42,
        image: "some image",
        industry: "some industry",
        is_etf: true,
        market_cap: 42,
        name: "some name",
        pe: 223.23,
        price: 212.21,
        sector: "some sector",
        symbol: "some symbol",
        volume: 32342,
        volume_avg: 23423,
        website: "some website"
      })
      |> Loin.FMP.create_fmp_security()

    fmp_security
  end

  @doc """
  Generate a daily_trend.
  """
  def daily_trend_fixture(attrs \\ %{}) do
    {:ok, daily_trend} =
      attrs
      |> Enum.into(%{
        close: 120.5,
        close_above_day_200_sma: true,
        close_above_day_50_sma: true,
        date: ~D[2023-01-09],
        day_200_sma: 120.5,
        day_50_sma: 120.5,
        day_50_sma_above_day_200_sma: true,
        is_valid: true,
        previous_close: 120.5,
        previous_close_above_day_200_sma: true,
        previous_close_above_day_50_sma: true,
        previous_day_200_sma: 120.5,
        previous_day_50_sma: 120.5,
        previous_day_50_sma_above_day_200_sma: true,
        previous_trend: "some previous_trend",
        previous_truthy_flags_count: 42,
        symbol: "AAPL",
        trend: "some trend",
        trend_change: "some trend_change",
        truthy_flags_count: 42,
        volume: 120.5
      })
      |> Loin.FMP.create_daily_trend()

    daily_trend
  end
end
