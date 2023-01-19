defmodule Loin.FMPTest do
  use Loin.DataCase

  alias Loin.FMP

  describe "fmp_securities" do
    alias Loin.FMP.FMPSecurity

    import Loin.FMPFixtures

    @invalid_attrs %{
      ceo: nil,
      change: nil,
      change_percent: nil,
      cik: nil,
      city: nil,
      country: nil,
      currency: nil,
      description: nil,
      eps: nil,
      exchange: nil,
      exchange_short_name: nil,
      full_time_employees: nil,
      image: nil,
      industry: nil,
      ipo_date: nil,
      is_etf: nil,
      last_dividend: nil,
      market_cap: nil,
      name: nil,
      pe: nil,
      price: nil,
      sector: nil,
      state: nil,
      symbol: nil,
      volume: nil,
      volume_avg: nil,
      website: nil
    }

    test "list_fmp_securities/0 returns all fmp_securities" do
      fmp_security = fmp_security_fixture()
      assert FMP.list_fmp_securities() == [fmp_security]
    end

    test "get_fmp_security!/1 returns the fmp_security with given id" do
      fmp_security = fmp_security_fixture()
      assert FMP.get_fmp_security!(fmp_security.id) == fmp_security
    end

    test "create_fmp_security/1 with valid data creates a fmp_security" do
      valid_attrs = %{
        ceo: "Mr. Elon Musk",
        change: 22321.1,
        change_percent: 12.3,
        cik: "234234234",
        city: "Chicago",
        country: "USD",
        currency: "US",
        description: "some description",
        eps: 21.3,
        exchange: "some exchange",
        exchange_short_name: "some exchange_short_name",
        full_time_employees: 42,
        image: "some image",
        industry: "some industry",
        ipo_date: "2022-01-02",
        is_etf: true,
        last_dividend: 13.2,
        market_cap: 42,
        name: "some name",
        pe: 2134.2,
        price: 134.23,
        sector: "some sector",
        state: "IL",
        symbol: "some symbol",
        volume: 2_342_342,
        volume_avg: 234_234,
        website: "some website"
      }

      assert {:ok, %FMPSecurity{} = fmp_security} = FMP.create_fmp_security(valid_attrs)
      assert fmp_security.description == "some description"
      assert fmp_security.exchange == "some exchange"
      assert fmp_security.exchange_short_name == "some exchange_short_name"
      assert fmp_security.full_time_employees == 42
      assert fmp_security.image == "some image"
      assert fmp_security.industry == "some industry"
      assert fmp_security.is_etf == true
      assert fmp_security.market_cap == 42
      assert fmp_security.name == "some name"
      assert fmp_security.sector == "some sector"
      assert fmp_security.symbol == "some symbol"
      assert fmp_security.website == "some website"
    end

    test "create_fmp_security/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FMP.create_fmp_security(@invalid_attrs)
    end

    test "update_fmp_security/2 with valid data updates the fmp_security" do
      fmp_security = fmp_security_fixture()

      update_attrs = %{
        description: "some updated description",
        exchange: "some updated exchange",
        exchange_short_name: "some updated exchange_short_name",
        full_time_employees: 43,
        image: "some updated image",
        industry: "some updated industry",
        is_etf: false,
        market_cap: 43,
        name: "some updated name",
        sector: "some updated sector",
        symbol: "some updated symbol",
        website: "some updated website"
      }

      assert {:ok, %FMPSecurity{} = fmp_security} =
               FMP.update_fmp_security(fmp_security, update_attrs)

      assert fmp_security.description == "some updated description"
      assert fmp_security.exchange == "some updated exchange"
      assert fmp_security.exchange_short_name == "some updated exchange_short_name"
      assert fmp_security.full_time_employees == 43
      assert fmp_security.image == "some updated image"
      assert fmp_security.industry == "some updated industry"
      assert fmp_security.is_etf == false
      assert fmp_security.market_cap == 43
      assert fmp_security.name == "some updated name"
      assert fmp_security.sector == "some updated sector"
      assert fmp_security.symbol == "some updated symbol"
      assert fmp_security.website == "some updated website"
    end

    test "update_fmp_security/2 with invalid data returns error changeset" do
      fmp_security = fmp_security_fixture()
      assert {:error, %Ecto.Changeset{}} = FMP.update_fmp_security(fmp_security, @invalid_attrs)
      assert fmp_security == FMP.get_fmp_security!(fmp_security.id)
    end

    test "delete_fmp_security/1 deletes the fmp_security" do
      fmp_security = fmp_security_fixture()
      assert {:ok, %FMPSecurity{}} = FMP.delete_fmp_security(fmp_security)
      assert_raise Ecto.NoResultsError, fn -> FMP.get_fmp_security!(fmp_security.id) end
    end

    test "change_fmp_security/1 returns a fmp_security changeset" do
      fmp_security = fmp_security_fixture()
      assert %Ecto.Changeset{} = FMP.change_fmp_security(fmp_security)
    end
  end

  describe "daily_trends" do
    alias Loin.FMP.DailyTrend

    import Loin.FMPFixtures

    @invalid_attrs %{
      close: nil,
      close_above_day_200_sma: nil,
      close_above_day_50_sma: nil,
      date: nil,
      day_200_sma: nil,
      day_50_sma: nil,
      day_50_sma_above_day_200_sma: nil,
      is_valid: nil,
      previous_close: nil,
      previous_close_above_day_200_sma: nil,
      previous_close_above_day_50_sma: nil,
      previous_day_200_sma: nil,
      previous_day_50_sma: nil,
      previous_day_50_sma_above_day_200_sma: nil,
      previous_trend: nil,
      previous_truthy_flags_count: nil,
      trend: nil,
      trend_change: nil,
      truthy_flags_count: nil,
      volume: nil
    }

    test "list_daily_trends/0 returns all daily_trends" do
      daily_trend = daily_trend_fixture()
      assert FMP.list_daily_trends() == [daily_trend]
    end

    test "get_daily_trend!/1 returns the daily_trend with given id" do
      daily_trend = daily_trend_fixture()
      assert FMP.get_daily_trend!(daily_trend.id) == daily_trend
    end

    test "create_daily_trend/1 with valid data creates a daily_trend" do
      valid_attrs = %{
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
      }

      assert {:ok, %DailyTrend{} = daily_trend} = FMP.create_daily_trend(valid_attrs)
      assert daily_trend.close == 120.5
      assert daily_trend.close_above_day_200_sma == true
      assert daily_trend.close_above_day_50_sma == true
      assert daily_trend.date == ~D[2023-01-09]
      assert daily_trend.day_200_sma == 120.5
      assert daily_trend.day_50_sma == 120.5
      assert daily_trend.day_50_sma_above_day_200_sma == true
      assert daily_trend.is_valid == true
      assert daily_trend.previous_close == 120.5
      assert daily_trend.previous_close_above_day_200_sma == true
      assert daily_trend.previous_close_above_day_50_sma == true
      assert daily_trend.previous_day_200_sma == 120.5
      assert daily_trend.previous_day_50_sma == 120.5
      assert daily_trend.previous_day_50_sma_above_day_200_sma == true
      assert daily_trend.previous_trend == "some previous_trend"
      assert daily_trend.previous_truthy_flags_count == 42
      assert daily_trend.trend == "some trend"
      assert daily_trend.trend_change == "some trend_change"
      assert daily_trend.truthy_flags_count == 42
      assert daily_trend.volume == 120.5
    end

    test "create_daily_trend/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FMP.create_daily_trend(@invalid_attrs)
    end

    test "update_daily_trend/2 with valid data updates the daily_trend" do
      daily_trend = daily_trend_fixture()

      update_attrs = %{
        close: 456.7,
        close_above_day_200_sma: false,
        close_above_day_50_sma: false,
        date: ~D[2023-01-10],
        day_200_sma: 456.7,
        day_50_sma: 456.7,
        day_50_sma_above_day_200_sma: false,
        is_valid: false,
        previous_close: 456.7,
        previous_close_above_day_200_sma: false,
        previous_close_above_day_50_sma: false,
        previous_day_200_sma: 456.7,
        previous_day_50_sma: 456.7,
        previous_day_50_sma_above_day_200_sma: false,
        previous_trend: "some updated previous_trend",
        previous_truthy_flags_count: 43,
        trend: "some updated trend",
        trend_change: "some updated trend_change",
        truthy_flags_count: 43,
        volume: 456.7
      }

      assert {:ok, %DailyTrend{} = daily_trend} =
               FMP.update_daily_trend(daily_trend, update_attrs)

      assert daily_trend.close == 456.7
      assert daily_trend.close_above_day_200_sma == false
      assert daily_trend.close_above_day_50_sma == false
      assert daily_trend.date == ~D[2023-01-10]
      assert daily_trend.day_200_sma == 456.7
      assert daily_trend.day_50_sma == 456.7
      assert daily_trend.day_50_sma_above_day_200_sma == false
      assert daily_trend.is_valid == false
      assert daily_trend.previous_close == 456.7
      assert daily_trend.previous_close_above_day_200_sma == false
      assert daily_trend.previous_close_above_day_50_sma == false
      assert daily_trend.previous_day_200_sma == 456.7
      assert daily_trend.previous_day_50_sma == 456.7
      assert daily_trend.previous_day_50_sma_above_day_200_sma == false
      assert daily_trend.previous_trend == "some updated previous_trend"
      assert daily_trend.previous_truthy_flags_count == 43
      assert daily_trend.trend == "some updated trend"
      assert daily_trend.trend_change == "some updated trend_change"
      assert daily_trend.truthy_flags_count == 43
      assert daily_trend.volume == 456.7
    end

    test "update_daily_trend/2 with invalid data returns error changeset" do
      daily_trend = daily_trend_fixture()
      assert {:error, %Ecto.Changeset{}} = FMP.update_daily_trend(daily_trend, @invalid_attrs)
      assert daily_trend == FMP.get_daily_trend!(daily_trend.id)
    end

    test "delete_daily_trend/1 deletes the daily_trend" do
      daily_trend = daily_trend_fixture()
      assert {:ok, %DailyTrend{}} = FMP.delete_daily_trend(daily_trend)
      assert_raise Ecto.NoResultsError, fn -> FMP.get_daily_trend!(daily_trend.id) end
    end

    test "change_daily_trend/1 returns a daily_trend changeset" do
      daily_trend = daily_trend_fixture()
      assert %Ecto.Changeset{} = FMP.change_daily_trend(daily_trend)
    end
  end
end
