defmodule LoinWeb.HeaderComponents do
  @moduledoc """
  Provides the Header components.
  """
  use Phoenix.Component
  use LoinWeb, :live_view

  alias Phoenix.LiveView.JS

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirm" on_confirm={JS.push("delete")} on_cancel={JS.navigate(~p"/posts")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  """
  attr :id, :string, required: true

  def unauthenticated(assigns) do
    ~H"""
    <div class="relative bg-white" id={@id}>
      <div class="px-4">
        <div class="flex items-center justify-between py-4 lg:justify-start lg:space-x-10">
          <a href="#" class="font-bold">
            Trenderloin
          </a>
          <div class="-my-2 -mr-2 lg:hidden">
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
              <input type="text" name="search" id="search" class="block w-full rounded-md border-gray-300 pr-12 shadow-sm focus:border-black focus:ring-black sm:text-sm" placeholder="Search by name or ticker">
              <div class="absolute inset-y-0 right-0 flex py-1.5 pr-1.5">
                <kbd class="inline-flex items-center rounded border border-gray-200 px-2 font-sans text-sm font-medium text-gray-400">⌘K</kbd>
              </div>
            </div>
          </div>
          <div class="hidden items-center justify-end lg:flex lg:flex-1 space-x-4 lg:w-0 text-sm">
            <.link href={~p"/users/log_in"} class="relative px-2 py-1 text-gray-500 hover:text-black">
              How it works
            </.link>
            <.link href={~p"/users/log_in"} class="relative px-2 py-1 text-gray-500 hover:text-black">
              Trend changes
            </.link>
            <.link href={~p"/users/log_in"} class="relative px-2 py-1 text-gray-500 hover:text-black">
              Watchlist
            </.link>
            <.link href={~p"/users/log_in"} class="relative px-2 py-1 text-gray-500 hover:text-black">
              Screener
            </.link>
            <.link href={~p"/users/log_in"} class="relative px-2 py-1 text-gray-500 hover:text-black">
              Charts
            </.link>
            <.link href={~p"/users/log_in"} class="relative group">
              <div class="absolute -inset-0.5 bg-gradient-to-r from-pink-600 to-purple-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-300 group-hover:duration-200"></div>
              <button class="relative px-3 py-1 bg-white rounded-md">
                Log in
              </button>
            </.link>
            <.link href={~p"/users/register"} class="relative group">
              <div class="absolute -inset-0.5 bg-gradient-to-r from-pink-600 to-purple-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-300 group-hover:duration-200 animate-tilt"></div>
              <button class="relative px-3 py-1 bg-black rounded-md text-white">
                Sign up
              </button>
            </.link>
          </div>
        </div>
      </div>

      <%!-- Mobile menu --%>
      <div
        class="absolute inset-x-0 top-0 origin-top-right transform transition hidden lg:hidden"
        id="mobile-menu"
      >
        <div class="divide-y-2 divide-gray-50 rounded-lg bg-white shadow-lg ring-1 ring-black ring-opacity-5">
          <div class="px-5 pt-5 pb-6">
            <div class="flex items-center justify-between">
              <div>
                <img
                  class="h-8 w-auto"
                  src="https://tailwindui.com/img/logos/mark.svg?color=indigo&shade=600"
                  alt="Your Company"
                />
              </div>
              <div class="-mr-2">
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
            </div>
            <div class="mt-6">
              <nav class="grid gap-y-8">
                <a href="#" class="-m-3 flex items-center rounded-md p-3 hover:bg-gray-50">
                  <svg
                    class="h-6 w-6 flex-shrink-0 text-indigo-600"
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
                      d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 013 19.875v-6.75zM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V8.625zM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V4.125z"
                    />
                  </svg>
                  <span class="ml-3 text-base font-medium text-gray-900">Analytics</span>
                </a>

                <a href="#" class="-m-3 flex items-center rounded-md p-3 hover:bg-gray-50">
                  <svg
                    class="h-6 w-6 flex-shrink-0 text-indigo-600"
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
                      d="M4.5 12c0-1.232.046-2.453.138-3.662a4.006 4.006 0 013.7-3.7 48.678 48.678 0 017.324 0 4.006 4.006 0 013.7 3.7c.017.22.032.441.046.662M4.5 12l-3-3m3 3l3-3m12 3c0 1.232-.046 2.453-.138 3.662a4.006 4.006 0 01-3.7 3.7 48.657 48.657 0 01-7.324 0 4.006 4.006 0 01-3.7-3.7c-.017-.22-.032-.441-.046-.662M19.5 12l-3 3m3-3l3 3"
                    />
                  </svg>
                  <span class="ml-3 text-base font-medium text-gray-900">Automations</span>
                </a>
              </nav>
            </div>
          </div>
          <div class="space-y-6 py-6 px-5">
            <div class="grid grid-cols-2 gap-y-4 gap-x-8">
              <a href="#" class="text-base font-medium text-gray-900 hover:text-gray-700">Pricing</a>

              <a href="#" class="text-base font-medium text-gray-900 hover:text-gray-700">Docs</a>

              <a href="#" class="text-base font-medium text-gray-900 hover:text-gray-700">
                Help Center
              </a>

              <a href="#" class="text-base font-medium text-gray-900 hover:text-gray-700">Guides</a>
            </div>
            <div>
              <a
                href="#"
                class="flex w-full items-center justify-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-base font-medium text-white shadow-sm hover:bg-indigo-700"
              >
                Sign up
              </a>
              <p class="mt-6 text-center text-base font-medium text-gray-500">
                Existing customer?
                <a href="#" class="text-indigo-600 hover:text-indigo-500">Sign in</a>
              </p>
            </div>
          </div>
        </div>
      </div>
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
