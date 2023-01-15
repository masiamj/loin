defmodule LoinWeb.SecurityLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, TimeseriesCache}

  @sector_symbols MapSet.new([
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
  def mount(%{"compare" => compare_symbol, "symbol" => symbol}, _session, socket) do
    proper_symbol = String.upcase(symbol)
    proper_compare_symbol = String.upcase(compare_symbol)

    [
      {:ok, %{^proper_symbol => proper, ^proper_compare_symbol => compare}},
      {:ok, chart_data},
      {:ok, compare_chart_data}
    ] =
      Task.await_many([
        Task.async(fn -> fetch_fmp_securities([proper_symbol, proper_compare_symbol]) end),
        Task.async(fn -> fetch_chart_data(proper_symbol) end),
        Task.async(fn -> fetch_chart_data(proper_compare_symbol) end)
      ])

    is_etf =
      proper
      |> Map.get(:security)
      |> Map.get(:is_etf)

    extra_information = fetch_more_relevant_information_for_security(proper.security)

    socket =
      socket
      |> assign(:is_etf, is_etf)
      |> assign(:symbol, proper_symbol)
      |> assign(:is_comparing, true)
      |> assign(:compare_symbol, compare_symbol)
      |> assign(:security, proper.security)
      |> assign(:compare_security, compare.security)
      |> assign(:timeseries_data, chart_data)
      |> assign(:compare_timeseries_data, compare_chart_data)
      |> assign(:trend, proper.trend)
      |> assign(:compare_trend, compare.trend)
      |> assign(extra_information)

    {:ok, socket}
  end

  @impl true
  def mount(%{"symbol" => symbol}, _session, socket) do
    proper_symbol = String.upcase(symbol)

    [
      {:ok, %{^proper_symbol => proper}},
      {:ok, chart_data}
    ] =
      Task.await_many([
        Task.async(fn -> fetch_fmp_security(proper_symbol) end),
        Task.async(fn -> fetch_chart_data(proper_symbol) end)
      ])

    is_etf =
      proper
      |> Map.get(:security)
      |> Map.get(:is_etf)

    extra_information = fetch_more_relevant_information_for_security(proper.security)

    socket =
      socket
      |> assign(:is_etf, is_etf)
      |> assign(:symbol, proper_symbol)
      |> assign(:is_comparing, false)
      |> assign(:security, proper.security)
      |> assign(:timeseries_data, chart_data)
      |> assign(:trend, proper.trend)
      |> assign(extra_information)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div class="col-span-1 h-[88vh] overflow-y-scroll">
          <div :if={!@is_etf} class="space-y-4">
            <LoinWeb.Cards.generic title="Similar stocks">
              <LoinWeb.Lists.similar_stocks data={assigns.peers} />
            </LoinWeb.Cards.generic>
            <LoinWeb.Cards.generic title="ETFs with exposure">
              <LoinWeb.Lists.etfs_with_exposures data={assigns.etf_exposures} />
            </LoinWeb.Cards.generic>
          </div>
          <div :if={@is_etf} class="space-y-4">
            <LoinWeb.Cards.generic
              :if={length(assigns.etf_sector_weights) > 0}
              title="Sector exposure"
            >
              <LoinWeb.Lists.etf_sector_weights data={assigns.etf_sector_weights} />
            </LoinWeb.Cards.generic>
            <LoinWeb.Cards.generic title="ETF constituents">
              <LoinWeb.Lists.etf_constituents data={assigns.etf_constituents} />
            </LoinWeb.Cards.generic>
          </div>
        </div>
        <div class="col-span-1 lg:col-span-2 h-[82vh] space-y-4">
          <LoinWeb.Cards.generic title={"#{@symbol} trend"}>
            <div
              class={"#{chart_height(@is_comparing)} w-full"}
              data-timeseries={@timeseries_data}
              id="timeseries_chart"
              phx-hook="TimeseriesChart"
              phx-update="ignore"
            >
            </div>
          </LoinWeb.Cards.generic>
          <LoinWeb.Cards.generic
            :if={@is_comparing}
            more_link={~p"/s/#{@compare_symbol}"}
            title={"#{@compare_symbol} trend"}
          >
            <div
              class={"#{chart_height(@is_comparing)} w-full"}
              data-timeseries={@compare_timeseries_data}
              id="compare_timeseries_chart"
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

    results_with_constituent =
      Enum.into(constituents, %{}, fn %{symbol: symbol} = constituent ->
        item =
          result_map
          |> Map.get(symbol, %{})
          |> Map.put(:constituent, constituent)

        {symbol, item}
      end)
      |> Map.values()
      |> Enum.sort_by(& &1.constituent.weight_percentage, :desc)

    {:ok, results_with_constituent}
  end

  defp fetch_etf_exposure(symbol) do
    exposures = FMP.Service.etf_exposure_by_stock(symbol)

    {:ok, result_map} =
      exposures
      |> Enum.map(&Map.get(&1, :etf_symbol))
      |> FMP.get_securities_by_symbols()

    results_with_exposure =
      Enum.into(exposures, %{}, fn %{etf_symbol: symbol} = exposure ->
        item =
          result_map
          |> Map.get(symbol, %{})
          |> Map.put(:exposure, exposure)

        {symbol, item}
      end)
      |> Map.values()
      |> Enum.sort_by(& &1.exposure.etf_weight_percentage, :desc)

    {:ok, results_with_exposure}
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

    results_with_sector_weight =
      Enum.into(sector_weights, %{}, fn sector_weight ->
        sector_name = Map.get(sector_weight, :sector)
        sector_etf_symbol = Map.get(@symbols_by_title, sector_name)
        sector_etf_title = Map.get(@titles_by_symbol, sector_etf_symbol)

        item =
          sector_trends
          |> Map.get(sector_etf_symbol, %{})
          |> Map.put(:sector_weight, Map.put(sector_weight, :name, sector_etf_title))

        {sector_etf_symbol, item}
      end)
      |> Map.values()
      |> Enum.sort_by(& &1.sector_weight.weight_percentage, :desc)

    {:ok, results_with_sector_weight}
  end

  defp fetch_peers(symbol) do
    {:ok, securities} =
      symbol
      |> FMP.Service.peers()
      |> FMP.get_securities_by_symbols()

    results =
      securities
      |> Map.values()
      |> Enum.sort_by(& &1.security.market_cap, :desc)

    {:ok, results}
  end

  defp fetch_fmp_security(symbol) do
    FMP.get_securities_by_symbols([symbol])
  end

  defp fetch_fmp_securities(symbols) when is_list(symbols) do
    FMP.get_securities_by_symbols(symbols)
  end

  defp fetch_more_relevant_information_for_security(%{is_etf: true, symbol: symbol}) do
    {:ok, etf_constituents} = fetch_etf_constituents(symbol)

    case MapSet.member?(@sector_symbols, symbol) do
      true ->
        %{etf_constituents: etf_constituents, etf_sector_weights: []}

      false ->
        {:ok, etf_sector_weights} = fetch_etf_sector_weights(symbol)
        %{etf_constituents: etf_constituents, etf_sector_weights: etf_sector_weights}
    end
  end

  defp fetch_more_relevant_information_for_security(%{is_etf: false, symbol: symbol}) do
    with {:ok, peers} <- fetch_peers(symbol),
         {:ok, etf_exposures} <- fetch_etf_exposure(symbol) do
      %{etf_exposures: etf_exposures, peers: peers}
    end
  end

  defp chart_height(is_comparing) when is_boolean(is_comparing) do
    case is_comparing do
      true -> "h-[37vh]"
      false -> "h-[82vh]"
    end
  end
end
