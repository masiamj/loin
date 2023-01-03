defmodule LoinWeb.FMPSecurityLiveTest do
  use LoinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Loin.FMPFixtures

  @create_attrs %{
    country: "US",
    currency: "USD",
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
  @update_attrs %{
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
  @invalid_attrs %{
    description: nil,
    exchange: nil,
    exchange_short_name: nil,
    full_time_employees: nil,
    image: nil,
    in_dow_jones: false,
    in_nasdaq: false,
    in_sp500: false,
    industry: nil,
    is_etf: false,
    market_cap: nil,
    name: nil,
    sector: nil,
    symbol: nil,
    website: nil
  }

  defp create_fmp_security(_) do
    fmp_security = fmp_security_fixture()
    %{fmp_security: fmp_security}
  end

  describe "Index" do
    setup [:create_fmp_security]

    test "lists all fmp_securities", %{conn: conn, fmp_security: fmp_security} do
      {:ok, _index_live, html} = live(conn, ~p"/fmp_securities")

      assert html =~ "Listing Fmp securities"
      assert html =~ fmp_security.description
    end

    # test "saves new fmp_security", %{conn: conn} do
    #   {:ok, index_live, _html} = live(conn, ~p"/fmp_securities")

    #   assert index_live |> element("a", "New Fmp security") |> render_click() =~
    #            "New Fmp security"

    #   assert_patch(index_live, ~p"/fmp_securities/new")

    #   assert index_live
    #          |> form("#fmp_security-form", fmp_security: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   {:ok, _, html} =
    #     index_live
    #     |> form("#fmp_security-form", fmp_security: @create_attrs)
    #     |> render_submit()
    #     |> follow_redirect(conn, ~p"/fmp_securities")

    #   assert html =~ "Fmp security created successfully"
    #   assert html =~ "some description"
    # end

    test "updates fmp_security in listing", %{conn: conn, fmp_security: fmp_security} do
      {:ok, index_live, _html} = live(conn, ~p"/fmp_securities")

      assert index_live
             |> element("#fmp_securities-#{fmp_security.id} a", "Edit")
             |> render_click() =~
               "Edit Fmp security"

      assert_patch(index_live, ~p"/fmp_securities/#{fmp_security}/edit")

      assert index_live
             |> form("#fmp_security-form", fmp_security: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#fmp_security-form", fmp_security: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/fmp_securities")

      assert html =~ "Fmp security updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes fmp_security in listing", %{conn: conn, fmp_security: fmp_security} do
      {:ok, index_live, _html} = live(conn, ~p"/fmp_securities")

      assert index_live
             |> element("#fmp_securities-#{fmp_security.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#fmp_security-#{fmp_security.id}")
    end
  end

  describe "Show" do
    setup [:create_fmp_security]

    test "displays fmp_security", %{conn: conn, fmp_security: fmp_security} do
      {:ok, _show_live, html} = live(conn, ~p"/fmp_securities/#{fmp_security}")

      assert html =~ "Show Fmp security"
      assert html =~ fmp_security.description
    end

    test "updates fmp_security within modal", %{conn: conn, fmp_security: fmp_security} do
      {:ok, show_live, _html} = live(conn, ~p"/fmp_securities/#{fmp_security}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Fmp security"

      assert_patch(show_live, ~p"/fmp_securities/#{fmp_security}/show/edit")

      assert show_live
             |> form("#fmp_security-form", fmp_security: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#fmp_security-form", fmp_security: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/fmp_securities/#{fmp_security}")

      assert html =~ "Fmp security updated successfully"
      assert html =~ "some updated description"
    end
  end
end
