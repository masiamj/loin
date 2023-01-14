defmodule LoinWeb.SecurityLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, TimeseriesCache}

  @symbols_by_title %{
    "Industrials" => "XLI",
    "Financial Services" => "XLF",
    "Consumer Cyclical" => "XLY",
    "Healthcare" => "XLV",
    "Basic Materials" => "XLB",
    "Communication Services" => "XLC",
    "Energy" => "XLE",
    "Consumer Defensive" => "XLP",
    "Technology" => "XLK",
    "Real Estate" => "XLRE",
    "Utilities" => "XLU"
  }

  @titles_by_symbol %{
    "XLB" => "Materials",
    "XLC" => "Communications",
    "XLE" => "Energy",
    "XLF" => "Financials",
    "XLI" => "Industrials",
    "XLK" => "Technology",
    "XLP" => "Consumer Staples",
    "XLRE" => "Real Estate",
    "XLU" => "Utilities",
    "XLV" => "Healthcare",
    "XLY" => "Consumer Discretionary",
    "GLD" => "Gold"
  }

  @impl true
  def mount(%{"symbol" => symbol}, _session, socket) do
    proper_symbol = String.upcase(symbol)

    with proper_symbol <- String.upcase(symbol),
         {:ok, %{^proper_symbol => %{security: security, trend: trend}}} <-
           fetch_fmp_security(proper_symbol),
         {:ok, chart_data} <- fetch_chart_data(proper_symbol),
         is_etf <- Map.get(security, :is_etf),
         extra_information <- fetch_more_relevant_information_for_security(security) do
      # IO.inspect(extra_information, label: "Extra")
      socket =
        socket
        |> assign(:is_etf, is_etf)
        |> assign(:symbol, proper_symbol)
        |> assign(:security, security)
        |> assign(:timeseries_data, chart_data)
        |> assign(:trend, trend)
        |> assign(extra_information)

      {:ok, socket}
    else
      _item -> {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div class="col-span-1 space-y-4">
          <LoinWeb.Cards.generic title="Similar stocks">
            <LoinWeb.Lists.stocks_with_trends data={assigns.peers} />
          </LoinWeb.Cards.generic>
          <LoinWeb.Cards.generic title="ETFs with exposure">
            <LoinWeb.Lists.etfs_with_exposures data={assigns.etf_exposures} />
          </LoinWeb.Cards.generic>
        </div>
        <div class="col-span-1 lg:col-span-2">
          <LoinWeb.Cards.generic title={"#{String.upcase(@symbol)} trend"}>
            <div
              class="h-96 w-full"
              data-timeseries={@timeseries_data}
              id="timeseries_chart"
              phx-hook="TimeseriesChart"
              phx-update="ignore"
            >
            </div>
          </LoinWeb.Cards.generic>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Home")
  end

  defp fetch_chart_data(symbol) do
    {:ok, {^symbol, data}} =
      symbol
      |> String.upcase()
      |> TimeseriesCache.get()

    Jason.encode(data)
  end

  defp fetch_etf_constituents(symbol) do
    constituents = FMP.Service.etf_holdings(symbol)

    {:ok, result_map} =
      constituents
      |> Enum.map(&Map.get(&1, :symbol, %{}))
      |> FMP.get_securities_by_symbols()

    result_map_with_constituent =
      Enum.reduce(constituents, result_map, fn %{symbol: symbol}, acc = constituent ->
        acc
        |> Map.get(symbol, %{})
        |> Map.put(:constituent, constituent)
      end)

    {:ok, result_map_with_constituent}
  end

  defp fetch_etf_exposure(symbol) do
    exposures = FMP.Service.etf_exposure_by_stock(symbol)
    |> Enum.sort_by(&Map.get(&1, :etf_weight_percentage), :desc)

    {:ok, result_map} =
      exposures
      |> Enum.map(&Map.get(&1, :etf_symbol))
      |> FMP.get_securities_by_symbols()

    result_map_with_exposure =
      Enum.into(exposures, %{}, fn %{etf_symbol: symbol} = exposure ->
        item =
          result_map
          |> Map.get(symbol, %{})
          |> Map.put(:exposure, exposure)

        {symbol, item}
      end)

    {:ok, result_map_with_exposure}
  end

  defp fetch_etf_sector_weights(symbol) do
    sector_weights = FMP.Service.etf_sector_weights(symbol)

    {:ok, sector_trends} =
      FMP.get_securities_by_symbols([
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

    result_map_with_sector_weight =
      Enum.reduce(sector_weights, sector_trends, fn sector_weight, acc ->
        sector_name = Map.get(sector_weight, :sector)
        sector_etf_symbol = Map.get(@symbols_by_title, sector_name)
        sector_etf_title = Map.get(@titles_by_symbol, sector_etf_symbol)

        acc
        |> Map.get(sector_etf_symbol, %{})
        |> Map.put(:sector_weight, Map.put(sector_weight, :name, sector_etf_title))
      end)

    {:ok, result_map_with_sector_weight}
  end

  defp fetch_peers(symbol) do
    symbol
    |> FMP.Service.peers()
    |> FMP.get_securities_by_symbols()
  end

  defp fetch_fmp_security(symbol) do
    FMP.get_securities_by_symbols([symbol])
  end

  defp fetch_more_relevant_information_for_security(%{is_etf: true, symbol: symbol}) do
    with {:ok, etf_constituents} <- fetch_etf_constituents(symbol),
         {:ok, etf_sector_weights} <- fetch_etf_sector_weights(symbol) do
      %{etf_constituents: etf_constituents, etf_sector_weights: etf_sector_weights}
    end
  end

  defp fetch_more_relevant_information_for_security(%{is_etf: false, symbol: symbol}) do
    with {:ok, peers} <- fetch_peers(symbol),
         {:ok, etf_exposures} <- fetch_etf_exposure(symbol) do
      %{etf_exposures: Map.values(etf_exposures), peers: Map.values(peers)}
    end
  end
end
