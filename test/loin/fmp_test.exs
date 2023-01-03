defmodule Loin.FMPTest do
  use Loin.DataCase

  alias Loin.FMP

  describe "fmp_securities" do
    alias Loin.FMP.FMPSecurity

    import Loin.FMPFixtures

    @invalid_attrs %{
      country: nil,
      currency: nil,
      description: nil,
      exchange: nil,
      exchange_short_name: nil,
      full_time_employees: nil,
      image: nil,
      in_dow_jones: nil,
      in_nasdaq: nil,
      in_sp500: nil,
      industry: nil,
      is_etf: nil,
      market_cap: nil,
      name: nil,
      sector: nil,
      symbol: nil,
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
        country: "USD",
        currency: "US",
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
      }

      assert {:ok, %FMPSecurity{} = fmp_security} = FMP.create_fmp_security(valid_attrs)
      assert fmp_security.description == "some description"
      assert fmp_security.exchange == "some exchange"
      assert fmp_security.exchange_short_name == "some exchange_short_name"
      assert fmp_security.full_time_employees == 42
      assert fmp_security.image == "some image"
      assert fmp_security.in_dow_jones == true
      assert fmp_security.in_nasdaq == true
      assert fmp_security.in_sp500 == true
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
        in_dow_jones: false,
        in_nasdaq: false,
        in_sp500: false,
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
      assert fmp_security.in_dow_jones == false
      assert fmp_security.in_nasdaq == false
      assert fmp_security.in_sp500 == false
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
end
