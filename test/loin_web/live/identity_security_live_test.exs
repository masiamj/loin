defmodule LoinWeb.IdentitySecurityLiveTest do
  use LoinWeb.ConnCase

  # import Phoenix.LiveViewTest
  # import Loin.AccountsFixtures

  # @create_attrs %{symbol: "some symbol"}
  # @update_attrs %{symbol: "some updated symbol"}
  # @invalid_attrs %{symbol: nil}

  # defp create_identity_security(_) do
  #   identity_security = identity_security_fixture()
  #   %{identity_security: identity_security}
  # end

  # describe "Index" do
  #   setup [:create_identity_security]

  #   test "lists all identity_securities", %{conn: conn, identity_security: identity_security} do
  #     {:ok, _index_live, html} = live(conn, ~p"/identity_securities")

  #     assert html =~ "Listing Identity securities"
  #     assert html =~ identity_security.symbol
  #   end

  #   test "saves new identity_security", %{conn: conn} do
  #     {:ok, index_live, _html} = live(conn, ~p"/identity_securities")

  #     assert index_live |> element("a", "New Identity security") |> render_click() =~
  #              "New Identity security"

  #     assert_patch(index_live, ~p"/identity_securities/new")

  #     assert index_live
  #            |> form("#identity_security-form", identity_security: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     {:ok, _, html} =
  #       index_live
  #       |> form("#identity_security-form", identity_security: @create_attrs)
  #       |> render_submit()
  #       |> follow_redirect(conn, ~p"/identity_securities")

  #     assert html =~ "Identity security created successfully"
  #     assert html =~ "some symbol"
  #   end

  #   test "updates identity_security in listing", %{conn: conn, identity_security: identity_security} do
  #     {:ok, index_live, _html} = live(conn, ~p"/identity_securities")

  #     assert index_live |> element("#identity_securities-#{identity_security.id} a", "Edit") |> render_click() =~
  #              "Edit Identity security"

  #     assert_patch(index_live, ~p"/identity_securities/#{identity_security}/edit")

  #     assert index_live
  #            |> form("#identity_security-form", identity_security: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     {:ok, _, html} =
  #       index_live
  #       |> form("#identity_security-form", identity_security: @update_attrs)
  #       |> render_submit()
  #       |> follow_redirect(conn, ~p"/identity_securities")

  #     assert html =~ "Identity security updated successfully"
  #     assert html =~ "some updated symbol"
  #   end

  #   test "deletes identity_security in listing", %{conn: conn, identity_security: identity_security} do
  #     {:ok, index_live, _html} = live(conn, ~p"/identity_securities")

  #     assert index_live |> element("#identity_securities-#{identity_security.id} a", "Delete") |> render_click()
  #     refute has_element?(index_live, "#identity_security-#{identity_security.id}")
  #   end
  # end

  # describe "Show" do
  #   setup [:create_identity_security]

  #   test "displays identity_security", %{conn: conn, identity_security: identity_security} do
  #     {:ok, _show_live, html} = live(conn, ~p"/identity_securities/#{identity_security}")

  #     assert html =~ "Show Identity security"
  #     assert html =~ identity_security.symbol
  #   end

  #   test "updates identity_security within modal", %{conn: conn, identity_security: identity_security} do
  #     {:ok, show_live, _html} = live(conn, ~p"/identity_securities/#{identity_security}")

  #     assert show_live |> element("a", "Edit") |> render_click() =~
  #              "Edit Identity security"

  #     assert_patch(show_live, ~p"/identity_securities/#{identity_security}/show/edit")

  #     assert show_live
  #            |> form("#identity_security-form", identity_security: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     {:ok, _, html} =
  #       show_live
  #       |> form("#identity_security-form", identity_security: @update_attrs)
  #       |> render_submit()
  #       |> follow_redirect(conn, ~p"/identity_securities/#{identity_security}")

  #     assert html =~ "Identity security updated successfully"
  #     assert html =~ "some updated symbol"
  #   end
  # end
end
