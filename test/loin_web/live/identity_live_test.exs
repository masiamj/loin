defmodule LoinWeb.IdentityLiveTest do
  use LoinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Loin.AccountsFixtures

  @create_attrs %{
    email: "some email",
    first_name: "some first_name",
    image_url: "some image_url",
    last_name: "some last_name"
  }
  @update_attrs %{
    email: "some updated email",
    first_name: "some updated first_name",
    image_url: "some updated image_url",
    last_name: "some updated last_name"
  }
  @invalid_attrs %{email: nil, first_name: nil, image_url: nil, last_name: nil}

  defp create_identity(_) do
    identity = identity_fixture()
    %{identity: identity}
  end

  describe "Index" do
    setup [:create_identity]

    test "lists all identities", %{conn: conn, identity: identity} do
      {:ok, _index_live, html} = live(conn, ~p"/identities")

      assert html =~ "Listing Identities"
      assert html =~ identity.email
    end

    test "saves new identity", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/identities")

      assert index_live |> element("a", "New Identity") |> render_click() =~
               "New Identity"

      assert_patch(index_live, ~p"/identities/new")

      assert index_live
             |> form("#identity-form", identity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#identity-form", identity: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/identities")

      assert html =~ "Identity created successfully"
      assert html =~ "some email"
    end

    test "updates identity in listing", %{conn: conn, identity: identity} do
      {:ok, index_live, _html} = live(conn, ~p"/identities")

      assert index_live |> element("#identities-#{identity.id} a", "Edit") |> render_click() =~
               "Edit Identity"

      assert_patch(index_live, ~p"/identities/#{identity}/edit")

      assert index_live
             |> form("#identity-form", identity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#identity-form", identity: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/identities")

      assert html =~ "Identity updated successfully"
      assert html =~ "some updated email"
    end

    test "deletes identity in listing", %{conn: conn, identity: identity} do
      {:ok, index_live, _html} = live(conn, ~p"/identities")

      assert index_live |> element("#identities-#{identity.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#identity-#{identity.id}")
    end
  end

  describe "Show" do
    setup [:create_identity]

    test "displays identity", %{conn: conn, identity: identity} do
      {:ok, _show_live, html} = live(conn, ~p"/identities/#{identity}")

      assert html =~ "Show Identity"
      assert html =~ identity.email
    end

    test "updates identity within modal", %{conn: conn, identity: identity} do
      {:ok, show_live, _html} = live(conn, ~p"/identities/#{identity}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Identity"

      assert_patch(show_live, ~p"/identities/#{identity}/show/edit")

      assert show_live
             |> form("#identity-form", identity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#identity-form", identity: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/identities/#{identity}")

      assert html =~ "Identity updated successfully"
      assert html =~ "some updated email"
    end
  end
end
