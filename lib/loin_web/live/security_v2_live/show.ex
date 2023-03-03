defmodule LoinWeb.SecurityV2Live do
  use LoinWeb, :live_view

  alias Loin.{
    Accounts,
    ETFConstituentsCache,
    ETFSectorWeightCache,
    FMP,
    PeersCache,
    StockETFExposureCache,
    TimeseriesCache
  }

  @impl true
  def mount(%{"symbol" => symbol}, _session, %{assigns: %{current_identity: identity}} = socket) do
    # Right-cases symbol from params
    proper_symbol = String.upcase(symbol)

    # Fetches the original security
    {:ok, %{^proper_symbol => security}} = FMP.get_securities_by_symbols([proper_symbol])

    # Fetches the timeseries chart data
    {:ok, {^proper_symbol, chart_data}} = TimeseriesCache.get_encoded(proper_symbol)

    # Fetches the item in the user's watchlist if available
    {:ok, identity_security} =
      Accounts.get_identity_security_by_identity_and_symbol(identity, proper_symbol)

    # Fetches ETF or Common stock-specific information
    %{page_title: page_title, sections: sections} = fetch_more_relevant_information(security)

    # Extracts realtime_symbols for each section
    [section_1_realtime_symbols, section_2_realtime_symbols] =
      Enum.map(sections, fn %{data: data} -> Enum.map(data, &Map.get(&1, :symbol)) end)

    # Assigns values to socket
    socket =
      socket
      |> assign(:is_in_watchlist, is_map(identity_security))
      |> assign(:original_symbol, proper_symbol)
      |> assign(:page_title, page_title)
      |> assign(:section_1_realtime_symbols, section_1_realtime_symbols)
      |> assign(:section_2_realtime_symbols, section_2_realtime_symbols)
      |> assign(:sections, sections)
      |> assign(:security, security)
      |> assign(:symbol, proper_symbol)
      |> assign(:timeseries_data, chart_data)
      |> assign(:timeseries_realtime_update, nil)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Loin.PubSub, "realtime_quotes")
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="grid grid-cols-1 lg:grid-cols-10 gap-y-4 lg:gap-y-0 divide-x lg:h-[94vh]">
        <div class="grid grid-cols-1 col-span-3 lg:max-h-[94vh]">
          <LoinWeb.Securities.security_quote
            is_in_watchlist={@is_in_watchlist}
            original_symbol={@original_symbol}
            security={@security}
          />
          <div class="lg:overflow-y-scroll">
            <LoinWeb.Securities.quote_section security={@security} />
            <div class="hidden lg:block">
              <%= for %{data: data, title: title} <- @sections do %>
                <p
                  :if={length(data) > 0}
                  class="py-2 px-3 bg-blue-50 text-xs font-medium sticky top-0 text-blue-500"
                >
                  <%= title %> (<%= length(data) %>)
                </p>
                <%= for item <- data do %>
                  <LoinWeb.Securities.security_list_item
                    class="border-b-[1px]"
                    id={item.symbol}
                    item={item}
                    phx-click="select-security"
                    phx-value-symbol={item.symbol}
                  />
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
        <div
          class="h-[40vh] lg:h-[94vh] w-full col-span-7 relative"
          data-timeseries={@timeseries_data}
          id="timeseries_chart"
          phx-hook="TimeseriesChart"
          phx-update="ignore"
          data-realtime-update={@timeseries_realtime_update}
        >
        </div>
        <div class="block lg:hidden">
          <%= for %{data: data, title: title} <- @sections do %>
            <p
              :if={length(data) > 0}
              class="py-2 px-3 bg-blue-50 text-xs font-medium sticky top-0 text-blue-500"
            >
              <%= title %> (<%= length(data) %>)
            </p>
            <%= for item <- data do %>
              <LoinWeb.Securities.security_list_item
                class="border-b-[1px]"
                id={item.symbol}
                item={item}
                phx-click="select-security"
                phx-value-symbol={item.symbol}
              />
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event(
        "select-security",
        %{"symbol" => proper_symbol},
        %{assigns: %{current_identity: identity}} = socket
      ) do
    # Fetches the newly selected security
    {:ok, %{^proper_symbol => security}} = FMP.get_securities_by_symbols([proper_symbol])

    # Fetches the timeseries chart data
    {:ok, {^proper_symbol, chart_data}} = TimeseriesCache.get_encoded(proper_symbol)

    # Fetches the item in the user's watchlist if available
    {:ok, identity_security} =
      Accounts.get_identity_security_by_identity_and_symbol(identity, proper_symbol)

    # Assigns values to socket
    socket =
      socket
      |> assign(:is_in_watchlist, is_map(identity_security))
      |> assign(:symbol, proper_symbol)
      |> assign(:security, security)
      |> assign(:timeseries_data, chart_data)
      |> assign(:timeseries_realtime_update, nil)

    {:noreply, socket}
  end

  @doc """
  Handles an unauthenticated user wanting to add a stock to their watchlist.
  """
  @impl true
  def handle_event(
        "toggle-identity-security",
        _params,
        %{assigns: %{current_identity: nil}} = socket
      ) do
    {:noreply, push_navigate(socket, to: "/auth")}
  end

  @doc """
  Handles an authenticated user toggling a stock on their watchlist.
  """
  @impl true
  def handle_event("toggle-identity-security", _params, socket) do
    case socket.assigns.is_in_watchlist do
      true ->
        Accounts.delete_identity_security_by_identity_and_symbol(
          socket.assigns.current_identity,
          socket.assigns.symbol
        )

        {:noreply, assign(socket, :is_in_watchlist, false)}

      false ->
        Accounts.create_identity_security(%{
          identity_id: socket.assigns.current_identity.id,
          symbol: socket.assigns.symbol
        })

        {:noreply, assign(socket, :is_in_watchlist, true)}
    end
  end

  @impl true
  def handle_info({:realtime_quotes, result_map}, socket) do
    # Extracts the securities that are actually important from the newly published quotes
    section_1_results = Map.take(result_map, socket.assigns.section_1_realtime_symbols)
    section_2_results = Map.take(result_map, socket.assigns.section_2_realtime_symbols)

    # Collect all IDs to trigger events on
    all_pertinent_results_symbols =
      Enum.concat([
        Map.keys(section_1_results),
        Map.keys(section_2_results)
      ])

    # Updates securities in the main list with their new values
    socket =
      socket
      |> update(
        :sections,
        fn [section_1, section_2] ->
          [
            update_section(section_1, section_1_results),
            update_section(section_2, section_2_results)
          ]
        end
      )
      |> assign(
        :security,
        Map.merge(socket.assigns.security, Map.get(result_map, socket.assigns.symbol, %{}))
      )
      |> assign(:timeseries_realtime_update, get_chart_realtime_updates(result_map, socket))

    {:noreply, push_event(socket, "flash-as-new-many", %{ids: all_pertinent_results_symbols})}
  end

  # Private

  defp fetch_more_relevant_information(%{is_etf: true, symbol: symbol}) do
    {:ok, etf_constituents} = ETFConstituentsCache.get_for_web(symbol)
    {:ok, etf_sector_weights} = ETFSectorWeightCache.get_for_web(symbol)

    %{}
    |> Map.put(:page_title, "#{symbol} ETF 60-day trend, sector exposure, and constituents")
    |> Map.put(:sections, [
      %{title: "Sector weights", data: etf_sector_weights},
      %{title: "ETF Constituents", data: etf_constituents}
    ])
  end

  defp fetch_more_relevant_information(%{is_etf: false, symbol: symbol}) do
    with {:ok, peers} <- PeersCache.get_for_web(symbol),
         {:ok, etf_exposures} <- StockETFExposureCache.get_for_web(symbol) do
      %{
        page_title: "#{symbol} 60-day trend, alternatives, and ETF exposures",
        sections: [
          %{title: "Similar stocks", data: peers},
          %{title: "ETF Exposure", data: etf_exposures}
        ]
      }
    end
  end

  defp get_chart_realtime_updates(result_map, socket) do
    case Map.get(result_map, socket.assigns.symbol) do
      nil -> socket.assigns.timeseries_realtime_update
      result when is_map(result) -> Jason.encode!(result)
    end
  end

  defp update_section(section, updates) do
    Map.update!(section, :data, fn data ->
      Enum.map(data, fn item -> Map.merge(item, Map.get(updates, item.symbol, %{})) end)
    end)
  end
end
