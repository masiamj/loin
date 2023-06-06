defmodule LoinWeb.HeaderComponents do
  @moduledoc """
  Provides the Header components.
  """
  use LoinWeb, :live_component

  @doc """
  Not sure why we need this, CoreComponents doesn't have it.

  The compiler is complaining and I don't have time to deal with it, so tossing it here.
  """
  def render(assigns) do
    ~H"""
    THIS IS A COMPILER PLACERHOLDER. DO NOT USE ME.
    """
  end

  @doc """
  Renders the top header component.
  """
  attr :id, :string, required: true

  def major(assigns) do
    ~H"""
    <div class="relative bg-black w-full h-[5vh]" id={@id}>
      <div class="w-full h-[5vh] bg-black">
        <div class="flex items-center justify-between h-full lg:justify-start px-4">
          <.link href={~p"/"} class="font-bold lg:w-1/3">
            <img alt="TrendFlares logo" class="h-10" src="/images/trendflares_logo_white.png" />
          </.link>
          <div class="lg:hidden">
            <button
              type="button"
              class="inline-flex items-center justify-center rounded-sm bg-orange-500 p-1 text-white hover:bg-orange-500 hover:text-white focus:outline-none focus:ring-2 focus:ring-inset focus:ring-orange-500"
              aria-expanded="false"
              phx-click={show_mobile_menu()}
            >
              <span class="sr-only">Open menu</span>
              <svg
                class="h-6 w-6"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                />
              </svg>
            </button>
          </div>
          <div class="hidden lg:flex w-1/3 px-2">
            <div class="relative w-full">
              <input
                type="text"
                name="header-search"
                id="header-search"
                class="block w-full rounded-md bg-neutral-900 pr-12 shadow-sm border-black focus:border-black focus:ring-orange-500 sm:text-sm text-orange-500"
                placeholder="Search by name or ticker"
                phx-hook="StockSearcher"
              />
              <div class="absolute inset-y-0 right-0 flex py-1.5 pr-1.5">
                <kbd class="inline-flex items-center px-2 font-sans text-sm font-medium text-neutral-500">
                  ⌘K
                </kbd>
              </div>
            </div>
          </div>
          <div class="hidden items-center justify-end lg:flex lg:flex-1 space-x-4 lg:w-0 text-sm">
            <.link navigate={~p"/how-it-works"} class="relative group">
              <div class="absolute -inset-0.5 bg-gradient-to-r from-pink-600 to-purple-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-300 group-hover:duration-200 animate-tilt">
              </div>
              <button class="relative px-3 py-1 bg-black rounded-md text-white">
                FAQ
              </button>
            </.link>
            <.link navigate={~p"/auth"} class="relative group">
              <div class="absolute -inset-0.5 bg-gradient-to-r from-pink-600 to-purple-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-300 group-hover:duration-200 animate-tilt">
              </div>
              <button class="relative px-3 py-1 bg-black rounded-md text-white">
                Log in
              </button>
            </.link>
          </div>
        </div>
        <div class="relative block lg:hidden w-full bg-black px-4 pt-1 pb-2">
          <input
            type="text"
            id="mobile-header-search"
            class="block w-full rounded-md bg-neutral-900 border-black pr-12 shadow-sm focus:border-black focus:ring-orange-500 sm:text-sm text-orange-500"
            placeholder="Search by name or ticker"
            phx-hook="StockSearcher"
          />
          <div class="absolute inset-y-0 right-0 flex items-center pr-6">
            <Heroicons.magnifying_glass class="h-5 w-5 stroke-neutral-500" />
          </div>
        </div>
        <.preset_pages />
      </div>

      <%!-- Mobile menu --%>
      <div
        class="absolute inset-x-0 top-0 origin-top-right transform transition hidden lg:hidden"
        id="mobile-menu"
      >
        <div class="rounded-b-lg bg-black shadow-lg ring-1 ring-orange ring-opacity-5">
          <div class="px-4 pt-0.5 pb-6">
            <div class="flex items-center justify-between">
              <.link navigate={~p"/"}>
                <img alt="TrendFlares logo" class="h-10" src="/images/trendflares_logo_white.png" />
              </.link>
              <button
                type="button"
                class="inline-flex items-center justify-center rounded-sm bg-orange-500 p-1 text-white hover:bg-orange-600"
                phx-click={hide_mobile_menu()}
              >
                <span class="sr-only">Close menu</span>
                <svg
                  class="h-6 w-6"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  aria-hidden="true"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <div class="mt-4 grid grid-cols-1 gap-y-4 px-4">
              <.link
                navigate={~p"/how-it-works"}
                class="text-white font-semibold hover:text-neutral-200"
              >
                FAQ
              </.link>
              <.link patch={~p"/auth"} class="text-white font-semibold hover:text-neutral-200">
                Log in
              </.link>
            </div>
          </div>
        </div>
      </div>
      <script>
        hotkeys('cmd+k', event => {
          event.preventDefault();
          document.getElementById('unauthenticated-header-search').focus()
        });
      </script>
    </div>
    """
  end

  ####################
  # Private
  ####################

  @doc """
  Renders an preset pages list.
  """
  def preset_pages(assigns) do
    ~H"""
    <div class="w-full bg-neutral-900 px-4 flex items-center overflow-x-scroll gap-4 py-2">
      <.navigation_link href="~p/how-it-works" label="Home" />
      <.navigation_link href="~p/how-it-works" label="Watchlist" />
      <.navigation_link href="~p/how-it-works" label="Markets" />
      <.navigation_link href="~p/how-it-works" label="S&P 500" />
      <.navigation_link href="~p/how-it-works" label="Nasdaq" />
      <.navigation_link href="~p/how-it-works" label="Dow Jones" />
      <.navigation_link href="~p/how-it-works" label="Russell 2K" />
      <.navigation_link href="~p/how-it-works" label="Bonds" />
      <.navigation_link href="~p/how-it-works" label="Sectors" />
      <.navigation_link href="~p/how-it-works" label="Strategies" />
      <.navigation_link href="~p/how-it-works" label="Countries" />
      <.navigation_link href="~p/how-it-works" label="Currencies" />
      <.navigation_link href="~p/how-it-works" label="Commodities" />
      <.navigation_link href="~p/how-it-works" label="Hedges" />
      <.navigation_link href="~p/how-it-works" label="Breakouts" />
    </div>
    """
  end

  ####################
  # Private
  ####################

  attr :href, :string, required: true
  attr :label, :string, required: true

  defp navigation_link(assigns) do
    ~H"""
    <.link class="font-semibold text-white text-xs hover:text-orange-300" navigate={@href}>
      <p style="min-width:0;overflow:hidden;white-space:nowrap;">
        <%= @label %>
      </p>
    </.link>
    """
  end

  ## JS Commands
  defp show_mobile_menu() do
    JS.show(
      to: "#mobile-menu",
      transition: {"transition-all transform ease-out duration-200", "opacity-0", "opacity-100"}
    )
  end

  defp hide_mobile_menu() do
    JS.hide(
      to: "#mobile-menu",
      transition: {"transition-all transform ease-out duration-200", "opacity-100", "opacity-0"}
    )
  end
end
