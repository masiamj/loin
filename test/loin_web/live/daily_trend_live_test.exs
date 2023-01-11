defmodule LoinWeb.DailyTrendLiveTest do
  use LoinWeb.ConnCase

  import Phoenix.LiveViewTest
  import Loin.FMPFixtures

  @create_attrs %{
    close: 120.5,
    close_above_day_200_sma: true,
    close_above_day_50_sma: true,
    date: "2023-1-9",
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
  @update_attrs %{
    close: 456.7,
    close_above_day_200_sma: false,
    close_above_day_50_sma: false,
    date: "2023-1-10",
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
    symbol: "AAPL",
    trend: "some updated trend",
    trend_change: "some updated trend_change",
    truthy_flags_count: 43,
    volume: 456.7
  }
  @invalid_attrs %{
    close: nil,
    close_above_day_200_sma: false,
    close_above_day_50_sma: false,
    date: nil,
    day_200_sma: nil,
    day_50_sma: nil,
    day_50_sma_above_day_200_sma: false,
    is_valid: false,
    previous_close: nil,
    previous_close_above_day_200_sma: false,
    previous_close_above_day_50_sma: false,
    previous_day_200_sma: nil,
    previous_day_50_sma: nil,
    previous_day_50_sma_above_day_200_sma: false,
    previous_trend: nil,
    previous_truthy_flags_count: nil,
    symbol: nil,
    trend: nil,
    trend_change: nil,
    truthy_flags_count: nil,
    volume: nil
  }

  defp create_daily_trend(_) do
    daily_trend = daily_trend_fixture()
    %{daily_trend: daily_trend}
  end

  describe "Index" do
    setup [:create_daily_trend]

    test "lists all daily_trends", %{conn: conn, daily_trend: daily_trend} do
      {:ok, _index_live, html} = live(conn, ~p"/daily_trends")

      assert html =~ "Listing Daily trends"
      assert html =~ daily_trend.previous_trend
    end

    # test "saves new daily_trend", %{conn: conn} do
    #   {:ok, index_live, _html} = live(conn, ~p"/daily_trends")

    #   assert index_live |> element("a", "New Daily trend") |> render_click() =~
    #            "New Daily trend"

    #   assert_patch(index_live, ~p"/daily_trends/new")

    #   assert index_live
    #          |> form("#daily_trend-form", daily_trend: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   {:ok, _, html} =
    #     index_live
    #     |> form("#daily_trend-form", daily_trend: @create_attrs)
    #     |> render_submit()
    #     |> follow_redirect(conn, ~p"/daily_trends")

    #   assert html =~ "Daily trend created successfully"
    #   assert html =~ "some previous_trend"
    # end

    # test "updates daily_trend in listing", %{conn: conn, daily_trend: daily_trend} do
    #   {:ok, index_live, _html} = live(conn, ~p"/daily_trends")

    #   assert index_live |> element("#daily_trends-#{daily_trend.id} a", "Edit") |> render_click() =~
    #            "Edit Daily trend"

    #   assert_patch(index_live, ~p"/daily_trends/#{daily_trend}/edit")

    #   assert index_live
    #          |> form("#daily_trend-form", daily_trend: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   {:ok, _, html} =
    #     index_live
    #     |> form("#daily_trend-form", daily_trend: @update_attrs)
    #     |> render_submit()
    #     |> follow_redirect(conn, ~p"/daily_trends")

    #   assert html =~ "Daily trend updated successfully"
    #   assert html =~ "some updated previous_trend"
    # end

    test "deletes daily_trend in listing", %{conn: conn, daily_trend: daily_trend} do
      {:ok, index_live, _html} = live(conn, ~p"/daily_trends")

      assert index_live
             |> element("#daily_trends-#{daily_trend.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#daily_trend-#{daily_trend.id}")
    end
  end

  describe "Show" do
    setup [:create_daily_trend]

    test "displays daily_trend", %{conn: conn, daily_trend: daily_trend} do
      {:ok, _show_live, html} = live(conn, ~p"/daily_trends/#{daily_trend}")

      assert html =~ "Show Daily trend"
      assert html =~ daily_trend.previous_trend
    end

    # test "updates daily_trend within modal", %{conn: conn, daily_trend: daily_trend} do
    #   {:ok, show_live, _html} = live(conn, ~p"/daily_trends/#{daily_trend}")

    #   assert show_live |> element("a", "Edit") |> render_click() =~
    #            "Edit Daily trend"

    #   assert_patch(show_live, ~p"/daily_trends/#{daily_trend}/show/edit")

    #   assert show_live
    #          |> form("#daily_trend-form", daily_trend: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   {:ok, _, html} =
    #     show_live
    #     |> form("#daily_trend-form", daily_trend: @update_attrs)
    #     |> render_submit()
    #     |> follow_redirect(conn, ~p"/daily_trends/#{daily_trend}")

    #   assert html =~ "Daily trend updated successfully"
    #   assert html =~ "some updated previous_trend"
    # end
  end
end
