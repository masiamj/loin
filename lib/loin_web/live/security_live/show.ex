defmodule LoinWeb.SecurityLive do
  use LoinWeb, :live_view

  alias Loin.{
    ETFConstituentsCache,
    ETFSectorWeightCache,
    FMP,
    PeersCache,
    StockETFExposureCache,
    TimeseriesCache
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-2 pt-7 pb-6 lg:py-4">
      <div class="p-3 bg-white border border-gray-200 flex flex-row flex-wrap justify-between gap-4 w-full mb-2">
        <div class="flex flex-col gap-1 w-full lg:w-2/5">
          <div class="flex flex-row items-center space-x-4">
            <h1 class="text-lg font-bold"><%= @security.name %> (<%= @symbol %>)</h1>

            <div class="flex flex-row items-center justify-end gap-2 text-xs">
              <LoinWeb.Securities.security_price security={@security} />
              <LoinWeb.Securities.security_change_percent security={@security} />
              <LoinWeb.Securities.security_change security={@security} />
            </div>
          </div>
          <p class="text-xs text-gray-500 line-clamp-2"><%= @security.description %></p>
        </div>
        <div class="grid grid-cols-2 lg:grid-cols-6 w-full lg:w-1/2 gap-4">
          <%= for %{title: title, value: value} <- @quote_data do %>
            <div class="flex flex-col">
              <p class="text-xs text-gray-500"><%= title %></p>
              <p class="text-xs"><%= value %></p>
            </div>
          <% end %>
        </div>
      </div>
      <div class="flex flex-row-reverse lg:flex-row flex-wrap items-start justify-between w-full">
        <div class="w-full lg:w-1/3 lg:h-[80vh] lg:overflow-y-scroll order-last lg:order-first mt-16 lg:mt-0 rounded-md">
          <ul class="grid grid-cols-1 border border-gray-200">
            <%= for %{data: data, title: title} <- @sections do %>
              <li :if={length(data) > 0}>
                <p class="py-3 px-2 bg-blue-100 text-sm text-blue-600 font-medium sticky top-0">
                  <%= title %> (<%= length(data) %>)
                </p>
                <ul>
                  <%= for item <- data do %>
                    <li class="border-b-[1px] border-gray-200">
                      <LoinWeb.Securities.generic_security item={item} />
                    </li>
                  <% end %>
                </ul>
              </li>
            <% end %>
          </ul>
        </div>
        <div class="w-full lg:w-2/3 h-[40vh] lg:h-[74vh] order-first lg:order-first lg:pl-2">
          <LoinWeb.Cards.generic title={"#{@symbol} trend"}>
            <div
              class="h-[40vh] lg:h-[74vh] w-full"
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
  def handle_params(%{"symbol" => symbol}, _url, socket) do
    mount_data = mount_impl(symbol)
    {:noreply, assign(socket, mount_data)}
  end

  # Private

  defp collate_security_information(security) do
    [
      %{
        title: "Market cap",
        value: Map.get(security, :market_cap)
      },
      %{
        title: "CEO",
        value: Map.get(security, :ceo)
      },
      %{
        title: "Full-time employees",
        value: Map.get(security, :full_time_employees)
      },
      %{
        title: "Headquarters",
        value: "#{Map.get(security, :city)}, #{Map.get(security, :state)}"
      },
      %{
        title: "EPS (TTM)",
        value: Map.get(security, :eps)
      },
      %{
        title: "PE Ratio",
        value: Map.get(security, :pe)
      }
    ]
  end

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

  defp mount_impl(symbol) do
    proper_symbol = String.upcase(symbol)

    with {:ok, %{^proper_symbol => %{security: security, trend: trend}}} <-
           FMP.get_securities_by_symbols([proper_symbol]),
         {:ok, {^proper_symbol, chart_data}} <- TimeseriesCache.get_encoded(proper_symbol),
         is_etf <- Map.get(security, :is_etf),
         extra_information <- fetch_more_relevant_information(security),
         quote_information <- collate_security_information(security) do
      %{}
      |> Map.put(:is_etf, is_etf)
      |> Map.put(:symbol, proper_symbol)
      |> Map.put(:security, security)
      |> Map.put(:timeseries_data, chart_data)
      |> Map.put(:trend, trend)
      |> Map.merge(extra_information)
      |> Map.put(:quote_data, quote_information)
    else
      _ -> %{}
    end
  end
end
