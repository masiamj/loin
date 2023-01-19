defmodule Loin.FMP do
  @moduledoc """
  The FMP context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Loin.Repo
  alias Loin.FMP.{DailyTrend, FMPSecurity}

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
    latest_daily_trends_query()
    |> filter_by_trend(trend)
    |> select([:symbol])
    |> limit(^limit_number)
    |> Repo.all()
    |> Enum.map(&Map.get(&1, :symbol))
    |> get_securities_by_symbols()
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
    latest_daily_trends_query()
    |> filter_by_has_trend_change()
    |> select([:symbol])
    |> limit(^limit_number)
    |> Repo.all()
    |> Enum.map(&Map.get(&1, :symbol))
    |> get_securities_by_symbols()
  end

  @doc """
  Inserts all fmp_securities into the table (a priming function).
  """
  def insert_all_profiles(limit \\ 20_000) do
    Loin.FMP.Service.all_profiles_stream()
    |> Stream.take(limit)
    |> Stream.chunk_every(10)
    |> Stream.each(&insert_many_fmp_securities/1)
    |> Stream.run()
  end

  # Private

  defp latest_daily_trends_query() do
    DailyTrend
    |> distinct(asc: :symbol)
    |> order_by(desc: :date)
    |> where(is_valid: true)
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

  defp insert_many_fmp_securities(entries, replace_all_except \\ [:id, :inserted_at, :symbol]) do
    symbols = Enum.map_join(entries, ", ", &Map.get(&1, :symbol))
    Logger.info("Inserting profiles for symbols: #{symbols}")

    {num_affected, nil} =
      Repo.insert_all(FMPSecurity, entries,
        on_conflict: {:replace_all_except, replace_all_except},
        conflict_target: [:symbol]
      )

    {:ok, num_affected}
  end

  defp query_into_map(query) do
    entries =
      query
      |> Repo.all()
      |> Enum.into(%{}, fn %{symbol: symbol} = item -> {symbol, item} end)

    {:ok, entries}
  end
end
