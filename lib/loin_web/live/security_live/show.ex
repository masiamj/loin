defmodule LoinWeb.SecurityLive do
  use LoinWeb, :live_view

  alias Loin.{FMP, PeersCache, TimeseriesCache}

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
  def mount(%{"symbol" => symbol}, _session, socket) do
    mount_data = mount_impl(symbol)
    socket = assign(socket, mount_data)
    {:ok, socket, temporary_assigns: [security: nil, timeseries_data: %{}, trend: nil]}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-8">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div class="col-span-1 h-[88vh] overflow-y-scroll">
          <div class="space-y-4">
            <LoinWeb.Cards.generic title="Similar stocks">
              <LoinWeb.Lists.similar_stocks data={assigns.peers} />
            </LoinWeb.Cards.generic>
            <%!-- <LoinWeb.Cards.generic title="ETFs with exposure">
              <LoinWeb.Lists.etfs_with_exposures data={assigns.etf_exposures} />
            </LoinWeb.Cards.generic> --%>
          </div>
          <div :if={false} class="space-y-4">
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
        <div class="col-span-1 lg:col-span-2 h-[82vh]">
          <LoinWeb.Cards.generic title={"#{@symbol} trend"}>
            <div
              class="h-[81vh] w-full"
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
  def handle_params(%{"symbol" => symbol} = params, _url, socket) do
    mount_data = mount_impl(symbol)

    socket =
      socket
      |> assign(mount_data)
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Home")
  end

  defp fetch_chart_data(symbol) do
    {:ok, %{^symbol => data}} = TimeseriesCache.get_many([symbol])
    {:ok, Jason.encode!(data)}
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
    with {:ok, {^symbol, peers_symbols}} <- PeersCache.get(symbol),
         {:ok, securities} <- FMP.get_securities_by_symbols(peers_symbols) do
      results =
        securities
        |> Map.values()
        |> Enum.sort_by(& &1.security.market_cap, :desc)

      {:ok, results}
    end
  end

  defp fetch_more_relevant_information(%{is_etf: true, symbol: symbol}) do
    {:ok, etf_constituents} = fetch_etf_constituents(symbol)

    case MapSet.member?(@sector_symbols, symbol) do
      true ->
        %{etf_constituents: etf_constituents, etf_sector_weights: []}

      false ->
        {:ok, etf_sector_weights} = fetch_etf_sector_weights(symbol)
        %{etf_constituents: etf_constituents, etf_sector_weights: etf_sector_weights}
    end
  end

  defp fetch_more_relevant_information(%{is_etf: false, symbol: symbol}) do
    with {:ok, peers} <- fetch_peers(symbol),
         {:ok, etf_exposures} <- fetch_etf_exposure(symbol) do
      %{etf_exposures: etf_exposures, peers: peers}
    end
  end

  defp mount_impl(symbol) do
    proper_symbol = String.upcase(symbol)

    with {:ok, %{^proper_symbol => %{security: security, trend: trend}}} <-
           FMP.get_securities_by_symbols([proper_symbol]),
         {:ok, chart_data} <- fetch_chart_data(symbol),
         is_etf <- Map.get(security, :is_etf),
         extra_information <- fetch_more_relevant_information(security) do
      %{}
      |> Map.put(:is_etf, is_etf)
      |> Map.put(:symbol, proper_symbol)
      |> Map.put(:security, security)
      |> Map.put(:timeseries_data, chart_data)
      |> Map.put(:trend, trend)
      |> Map.merge(extra_information)
    else
      _ -> %{}
    end
  end
end
