defmodule LoinWeb.BigBoardLive do
  use LoinWeb, :live_view

  @board_items [
    %{
      label: "Markets",
      securities: [
        %{symbol: "DIA"},
        %{symbol: "DVY"},
        %{symbol: "IJH"},
        %{symbol: "IJJ"},
        %{symbol: "IJK"},
        %{symbol: "IJR"},
        %{symbol: "IJS"},
        %{symbol: "IJT"},
        %{symbol: "IVE"},
        %{symbol: "IVV"},
        %{symbol: "IVW"},
        %{symbol: "IWB"},
        %{symbol: "IWC"},
        %{symbol: "IWM"},
        %{symbol: "IWR"},
        %{symbol: "MDY"},
        %{symbol: "OEF"},
        %{symbol: "QQQ"},
        %{symbol: "RSP"},
        %{symbol: "SPY"},
        %{symbol: "VOO"},
        %{symbol: "VTI"}
      ]
    },
    %{
      label: "Sectors",
      securities: [
        %{symbol: "XLB"},
        %{symbol: "XLC"},
        %{symbol: "XLE"},
        %{symbol: "XLF"},
        %{symbol: "XLI"},
        %{symbol: "XLK"},
        %{symbol: "XLK"},
        %{symbol: "XLP"},
        %{symbol: "XLRE"},
        %{symbol: "XLU"},
        %{symbol: "XLV"},
        %{symbol: "XLY"}
      ]
    },
    %{
      label: "Countries",
      securities: [
        %{symbol: "ASHR"},
        %{symbol: "ECH"},
        %{symbol: "EPHE"},
        %{symbol: "EWA"},
        %{symbol: "EWC"},
        %{symbol: "EWD"},
        %{symbol: "EWG"},
        %{symbol: "EWH"},
        %{symbol: "EWI"},
        %{symbol: "EWJ"},
        %{symbol: "EWL"},
        %{symbol: "EWM"},
        %{symbol: "EWN"},
        %{symbol: "EWP"},
        %{symbol: "EWQ"},
        %{symbol: "EWS"},
        %{symbol: "EWT"},
        %{symbol: "EWU"},
        %{symbol: "EWW"},
        %{symbol: "EWY"},
        %{symbol: "EWZ"},
        %{symbol: "EZA"},
        %{symbol: "GXG"},
        %{symbol: "IDX"},
        %{symbol: "PIN"},
        %{symbol: "RSX"},
        %{symbol: "SPY"},
        %{symbol: "THD"},
        %{symbol: "TUR"},
        %{symbol: "VNM"}
      ]
    },
    %{
      label: "Bonds",
      securities: [
        %{symbol: "AGG"},
        %{symbol: "BIL"},
        %{symbol: "BIV"},
        %{symbol: "BKLN"},
        %{symbol: "BLV"},
        %{symbol: "BND"},
        %{symbol: "BOND"},
        %{symbol: "BSV"},
        %{symbol: "EDV"},
        %{symbol: "EMB"},
        %{symbol: "HYG"},
        %{symbol: "IEF"},
        %{symbol: "IEI"},
        %{symbol: "IGSB"},
        %{symbol: "JNK"},
        %{symbol: "LQD"},
        %{symbol: "MBB"},
        %{symbol: "PFF"},
        %{symbol: "PGF"},
        %{symbol: "PGX"},
        %{symbol: "SHM"},
        %{symbol: "SHV"},
        %{symbol: "SHY"},
        %{symbol: "SNLN"},
        %{symbol: "SPSB"},
        %{symbol: "STPZ"},
        %{symbol: "TIP"},
        %{symbol: "TLH"},
        %{symbol: "TLT"},
        %{symbol: "VCLT"},
        %{symbol: "VCSH"}
      ]
    },
    %{
      label: "Commodities",
      securities: [
        %{symbol: "DBA"},
        %{symbol: "DBB"},
        %{symbol: "DBC"},
        %{symbol: "DBE"},
        %{symbol: "DBO"},
        %{symbol: "DBP"},
        %{symbol: "DGL"},
        %{symbol: "DJP"},
        %{symbol: "GLD"},
        %{symbol: "IAU"},
        %{symbol: "MOO"},
        %{symbol: "SLV"},
        %{symbol: "UNG"},
        %{symbol: "USO"}
      ]
    },
    %{
      label: "Hedges",
      securities: [
        %{symbol: "AGQ"},
        %{symbol: "DUST"},
        %{symbol: "DXD"},
        %{symbol: "DZZ"},
        %{symbol: "EDC"},
        %{symbol: "EDZ"},
        %{symbol: "ERY"},
        %{symbol: "EUM"},
        %{symbol: "EUO"},
        %{symbol: "FAS"},
        %{symbol: "FAZ"},
        %{symbol: "MVV"},
        %{symbol: "NUGT"},
        %{symbol: "PSQ"},
        %{symbol: "QID"},
        %{symbol: "QLD"},
        %{symbol: "RWM"},
        %{symbol: "SARK"},
        %{symbol: "SCO"},
        %{symbol: "SDOW"},
        %{symbol: "SDS"},
        %{symbol: "SH"},
        %{symbol: "SJB"},
        %{symbol: "SPXL"},
        %{symbol: "SPXS"},
        %{symbol: "SPXU"},
        %{symbol: "SQQQ"},
        %{symbol: "SSO"},
        %{symbol: "SVXY"},
        %{symbol: "TBF"},
        %{symbol: "TBT"},
        %{symbol: "TNA"},
        %{symbol: "TQQQ"},
        %{symbol: "TWM"},
        %{symbol: "TZA"},
        %{symbol: "UCO"},
        %{symbol: "UPRO"},
        %{symbol: "UST"},
        %{symbol: "UVXY"},
        %{symbol: "UWM"},
        %{symbol: "VIXY"}
      ]
    },
    %{
      label: "Currencies",
      securities: [
        %{symbol: "EWG"},
        %{symbol: "EWH"},
        %{symbol: "EWI"},
        %{symbol: "EWJ"},
        %{symbol: "EWL"},
        %{symbol: "EWM"},
        %{symbol: "EWN"},
        %{symbol: "EWP"},
        %{symbol: "EWQ"},
        %{symbol: "EWS"},
        %{symbol: "EWT"},
        %{symbol: "EWU"},
        %{symbol: "EWW"},
        %{symbol: "EWY"},
        %{symbol: "EWZ"},
        %{symbol: "EZA"},
        %{symbol: "GXG"},
        %{symbol: "IDX"},
        %{symbol: "PIN"},
        %{symbol: "RSX"},
        %{symbol: "SPY"},
        %{symbol: "THD"},
        %{symbol: "TUR"},
        %{symbol: "VNM"}
      ]
    },
    %{
      label: "Strategies",
      securities: [
        %{symbol: "PKW"},
        %{symbol: "RSP"},
        %{symbol: "SDY"},
        %{symbol: "SPLV"},
        %{symbol: "VIG"},
        %{symbol: "VTV"},
        %{symbol: "VUG"},
        %{symbol: "XXX"},
        %{symbol: "XXX"},
        %{symbol: "XXX"},
        %{symbol: "XXX"},
        %{symbol: "XXX"},
        %{symbol: "XXX"},
        %{symbol: "XXX"},
        %{symbol: "XXX"}
      ]
    },
    %{
      label: "Mega-caps",
      securities: [
        %{symbol: "AAPL"},
        %{symbol: "AMZN"},
        %{symbol: "MSFT"},
        %{symbol: "GOOGL"},
        %{symbol: "NVDA"},
        %{symbol: "BRK.B"},
        %{symbol: "TSLA"},
        %{symbol: "META"},
        %{symbol: "TSM"},
        %{symbol: "V"},
        %{symbol: "UNH"},
        %{symbol: "XOM"},
        %{symbol: "LLY"},
        %{symbol: "JNJ"},
        %{symbol: "JPM"}
      ]
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        :page_title,
        "How TrendFlares works: revolutionize your investment strategy with real-time trends and analysis"
      )
      |> assign(:board, @board_items)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-neutral-900">
      <div class="flex flex-row">
        <div class="flex flex-col w-1/4 md:w-1/3 lg:w-1/12">
          <%= for %{label: label} <- @board do %>
            <div class="px-4 py-8 bg-black border border-1 border-neutral-400 text-white font-bold">
              <%= label %>
            </div>
          <% end %>
        </div>
        <div class="flex flex-col overflow-x-scroll w-3/4 md:w-2/3 lg:w-11/12 w-full">
          <%= for %{securities: securities} <- @board do %>
            <div class="flex flex-row w-full bg-green-500">
              <%= for security <- Enum.take(securities, 12) do %>
                <div class={[
                  get_random_background_color(),
                  "big-board-security",
                  "px-4 py-8 text-white border border-1 border-neutral-400 lg:flex lg:flex-1"
                ]}>
                  <%= security.symbol %>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    <LoinWeb.FooterComponents.footer />
    """
  end

  defp get_random_background_color() do
    Enum.random(["bg-green-700", "bg-red-700", "bg-yellow-700"])
  end
end
