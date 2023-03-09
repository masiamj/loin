defmodule Loin.FMP do
  @moduledoc """
  The FMP context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias Loin.Repo
  alias Loin.FMP.{Screener}

  @doc """
  Queries against the screener view with dynamic params.
  """
  def filter_screener(params \\ %{}) do
    Screener
    |> where([s], s.market_cap > 0)
    |> where([s], s.price > 0.01)
    |> Flop.validate_and_run(params, for: Screener)
  end

  @doc """
  Gets the most recent daily sector trends.

  ## Examples

      iex> get_sector_etfs
      {:ok, %{}}

  """
  def get_sector_etfs do
    get_securities_by_symbols([
      # "VTI",
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

  def get_securities_by_symbols(symbols) do
    items =
      base_screener_query()
      |> where([s], s.symbol in ^symbols)
      |> Repo.all()
      |> Enum.into(%{}, fn %{symbol: symbol} = item -> {symbol, item} end)

    {:ok, items}
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
    items =
      base_screener_query()
      |> where(trend: ^trend)
      |> limit(^limit_number)
      |> Repo.all()
      |> key_by_symbol()

    {:ok, items}
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
    items =
      base_screener_query()
      |> where([s], not is_nil(s.trend_change))
      |> limit(^limit_number)
      |> Repo.all()
      |> key_by_symbol()

    {:ok, items}
  end

  # Private

  defp base_screener_query do
    from(s in Screener,
      where: not is_nil(s.market_cap),
      where: s.market_cap > 0,
      order_by: [desc: s.market_cap]
    )
  end

  defp key_by_symbol(items) when is_list(items) do
    Enum.into(items, %{}, fn %{symbol: symbol} = item -> {symbol, item} end)
  end
end
