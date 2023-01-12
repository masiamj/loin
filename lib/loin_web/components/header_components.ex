defmodule LoinWeb.HeaderComponents do
  @moduledoc """
  Provides the Header components.
  """
  use LoinWeb, :live_view

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
  Renders an unauthenticated header.
  """
  attr :id, :string, required: true

  def unauthenticated(assigns) do
    ~H"""
    <div class="relative bg-white" id={@id}>
      <div class="px-4 pb-4 lg:pb-0">
        <div class="flex items-center justify-between py-2 lg:justify-start lg:space-x-10">
          <a href="#" class="font-bold">
            Trenderloin
          </a>
          <div class="lg:hidden">
            <button
              type="button"
              class="inline-flex items-center justify-center rounded-md bg-white p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"
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
          <div class="hidden lg:flex lg:flex-1 justify-center">
            <div class="relative w-3/5">
              <input
                type="text"
                name="unauthenticated-header-search"
                id="unauthenticated-header-search"
                class="block w-full rounded-md border-gray-300 pr-12 shadow-sm focus:border-black focus:ring-black sm:text-sm"
                placeholder="Search by name or ticker"
              />
              <div class="absolute inset-y-0 right-0 flex py-1.5 pr-1.5">
                <kbd class="inline-flex items-center rounded border border-gray-200 px-2 font-sans text-sm font-medium text-gray-400">
                  ⌘K
                </kbd>
              </div>
            </div>
          </div>
          <div class="hidden items-center justify-end lg:flex lg:flex-1 space-x-4 lg:w-0 text-sm">
            <.link href={~p"/users/log_in"} class="relative px-2 py-1 text-gray-500 hover:text-black">
              How it works
            </.link>
            <.link href={~p"/users/log_in"} class="relative px-2 py-1 text-gray-500 hover:text-black">
              Screener
            </.link>
            <.link href={~p"/users/log_in"} class="relative px-2 py-1 text-gray-500 hover:text-black">
              Charts
            </.link>
            <.link href={~p"/users/log_in"} class="relative group">
              <div class="absolute -inset-0.5 bg-gradient-to-r from-pink-600 to-purple-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-300 group-hover:duration-200">
              </div>
              <button class="relative px-3 py-1 bg-white rounded-md">
                Log in
              </button>
            </.link>
            <.link href={~p"/users/register"} class="relative group">
              <div class="absolute -inset-0.5 bg-gradient-to-r from-pink-600 to-purple-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-300 group-hover:duration-200 animate-tilt">
              </div>
              <button class="relative px-3 py-1 bg-black rounded-md text-white">
                Sign up
              </button>
            </.link>
          </div>
        </div>
        <div class="relative block lg:hidden">
          <input
            type="text"
            name="unauthenticated-header-search"
            id="unauthenticated-header-search"
            class="block w-full rounded-md border-gray-300 pr-12 shadow-sm focus:border-black focus:ring-black sm:text-sm"
            placeholder="Search by name or ticker"
          />
          <div class="absolute inset-y-0 right-0 flex items-center pr-2">
            <Heroicons.magnifying_glass class="h-5 w-5 stroke-gray-400" />
          </div>
        </div>
      </div>

      <%!-- Mobile menu --%>
      <div
        class="absolute inset-x-0 top-0 origin-top-right transform transition hidden lg:hidden"
        id="mobile-menu"
      >
        <div class="rounded-lg bg-white shadow-lg ring-1 ring-black ring-opacity-5">
          <div class="px-5 pt-5 pb-6">
            <div class="flex items-center justify-between">
              <a href="#" class="font-bold">
                Trenderloin
              </a>
              <button
                type="button"
                class="inline-flex items-center justify-center rounded-md bg-white p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"
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
            <div class="mt-4">
              <nav class="grid gap-y-1">
                <.link href={~p"/users/log_in"} class="rounded-md px-3 py-2 hover:bg-gray-100">
                  How it works
                </.link>
                <.link href={~p"/users/log_in"} class="rounded-md px-3 py-2 hover:bg-gray-100">
                  Screener
                </.link>
                <.link href={~p"/users/log_in"} class="rounded-md px-3 py-2 hover:bg-gray-100">
                  Charts
                </.link>
              </nav>
            </div>
          </div>
          <div class="px-8 pb-4 flex flex-row items-center space-x-8 w-full">
            <.link href={~p"/users/log_in"} class="relative group w-full">
              <div class="absolute -inset-0.5 bg-gradient-to-r from-pink-600 to-purple-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-300 group-hover:duration-200">
              </div>
              <button class="relative px-3 py-1 bg-white border border-gray-300 rounded-md w-full">
                Log in
              </button>
            </.link>
            <.link href={~p"/users/register"} class="relative group w-full">
              <div class="absolute -inset-0.5 bg-gradient-to-r from-pink-600 to-purple-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-300 group-hover:duration-200 animate-tilt">
              </div>
              <button class="relative px-3 py-1 bg-black rounded-md text-white w-full">
                Sign up
              </button>
            </.link>
          </div>
        </div>
      </div>
      <script>
              hotkeys('cmd+k', event => {
                event.preventDefault();
                document.getElementById('unauthenticated-header-search').focus()
                console.log('done')
          }
        );
      </script>
    </div>
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
    IO.puts("hide_mobile_menu")

    JS.hide(
      to: "#mobile-menu",
      transition: {"transition-all transform ease-out duration-200", "opacity-100", "opacity-0"}
    )
  end
end
