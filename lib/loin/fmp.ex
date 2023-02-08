defmodule Loin.FMP do
  @moduledoc """
  The FMP context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Loin.Repo
  alias Loin.FMP.{DailyTrend, FMPSecurity, Screener, TTMRatio}

  @doc """
  Queries against the screener view with dynamic params.
  """
  def filter_screener(params \\ %{}) do
    final_filters =
      params
      |> Map.get("filters", %{})
      |> IO.inspect(label: "Initial filters")
      |> Enum.filter(fn {_key, %{"value" => value}} -> value != "" end)
      |> Enum.into(%{})
      |> IO.inspect(label: "Final filters")

    final_params = Map.put(params, "filters", final_filters)
    IO.inspect(final_params, label: "Final params")

    Flop.validate_and_run(Screener, final_params, for: Screener)
  end

  @doc """
  Gets the most recent daily sector trends.

  ## Examples

      iex> get_daily_sector_trends
      [%DailyTrend{}]

  """
  def get_daily_sector_trends do
    get_securities_by_symbols([
      "GLD",
      "XLB",
      "XLC",
      "XLE",
      "XLF",
      "XLI",
      "XLK",
      "XLP",
      "XLRE",
      "XLU",
      "XLV",
      "XLY"
    ])
  end

  @doc """
  Gets many fmp_securities and daily_trends by their symbols.

  ## Examples

      iex> get_fmp_securities_by_symbols(["AAPL"])
      {:ok, %{}}

  """
  def get_securities_by_symbols([]), do: {:ok, %{}}

  def get_securities_by_symbols(symbols) when is_list(symbols) do
    {:ok, trends} =
      latest_daily_trends_query()
      |> filter_by_symbols(symbols)
      |> query_into_map()

    {:ok, securities} =
      fmp_securities_query()
      |> filter_by_symbols(symbols)
      |> query_into_map()

    entries =
      Enum.into(securities, %{}, fn {symbol, security} ->
        {symbol, %{security: security, trend: Map.get(trends, symbol, nil)}}
      end)

    {:ok, entries}
  end

  @doc """
  Gets a list of combined fmp_securities and daily_trends.

  Filters by securities with a specific trend, and returns them sorted by market_cap desc.

  ## Examples

      iex> get_securities_via_trend("up", 2)
      [%{}, %{}]

  """
  def get_securities_via_trend(trend, limit_number \\ 50)
      when trend in ["down", "up"] and is_integer(limit_number) do
    trends_query =
      latest_daily_trends_query()
      |> filter_by_trend(trend)

    entries =
      from(fs in FMPSecurity,
        join: dt in subquery(trends_query),
        on: fs.symbol == dt.symbol,
        where: not is_nil(fs.market_cap),
        order_by: [desc: fs.market_cap],
        limit: ^limit_number,
        select: %{security: fs, trend: dt}
      )
      |> Repo.all()
      |> Enum.into(%{}, fn %{security: security} = item ->
        {security.symbol, item}
      end)

    {:ok, entries}
  end

  @doc """
  Gets a list of combined fmp_securities and daily_trends.

  Filters by securities with a trend change, and returns them sorted by market_cap desc.

  ## Examples

      iex> get_securities_with_trend_change("up", 2)
      [%{}, %{}]

  """
  def get_securities_with_trend_change(limit_number \\ 50)
      when is_integer(limit_number) do
    trends_query =
      latest_daily_trends_query()
      |> filter_by_has_trend_change()

    entries =
      from(fs in FMPSecurity,
        join: dt in subquery(trends_query),
        on: fs.symbol == dt.symbol,
        where: not is_nil(fs.market_cap),
        order_by: [desc: fs.market_cap],
        limit: ^limit_number,
        select: %{security: fs, trend: dt}
      )
      |> Repo.all()
      |> Enum.into(%{}, fn %{security: security} = item ->
        {security.symbol, item}
      end)

    {:ok, entries}
  end

  @doc """
  Gets the ttm_ratios for a specific security.

  ## Examples

      iex> get_ttm_ratios_by_symbol("AAPL")
      {:ok, %{}}

  """
  def get_ttm_ratios_by_symbol(symbol) when is_binary(symbol) do
    result = Repo.get_by(TTMRatio, symbol: symbol)
    {:ok, result}
  end

  # Private

  defp latest_daily_trends_query() do
    from(dt in DailyTrend,
      distinct: [asc: :symbol],
      order_by: [desc: :date],
      where: [is_valid: true]
    )
  end

  defp fmp_securities_query() do
    from(fs in FMPSecurity,
      where: not is_nil(fs.market_cap),
      order_by: [desc: fs.market_cap]
    )
  end

  defp filter_by_symbols(query, symbols) when is_list(symbols),
    do: where(query, [e], e.symbol in ^symbols)

  defp filter_by_has_trend_change(query), do: where(query, [dt], not is_nil(dt.trend_change))

  defp filter_by_trend(query, trend) when trend in ["up", "down"], do: where(query, trend: ^trend)

  defp query_into_map(query) do
    entries =
      query
      |> Repo.all()
      |> Enum.into(%{}, fn %{symbol: symbol} = item -> {symbol, item} end)

    {:ok, entries}
  end
end
