defmodule LoinWeb.AuthenticateLive do
  use LoinWeb, :live_view

  alias Loin.Accounts
  alias Loin.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="flex flex-col py-24 mx-auto max-w-md lg:min-h-[94vh]">
      <h1 class="text-4xl font-extrabold text-center">Join TrendFlares for free</h1>
      <p class="text-gray-500 text-center mt-2 text-sm">
        Log in to create a watchlist <span class="text-blue-500">(alerts coming soon!)</span>
      </p>
      <div class="mt-8 relative group">
        <div class="absolute -inset-0.5 bg-gradient-to-r from-indigo-600 to-pink-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-300 group-hover:duration-200 animate-tilt">
        </div>
        <link href="https://fonts.googleapis.com/css?family=Roboto&display=swap" />
        <div class="flex bg-blue-500 border-2 border-blue-500 w-full rounded-sm shadow-lg relative">
          <div class="w-1/5 bg-white flex items-center justify-center p-3">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 533.5 544.3"
              width="52px"
              height="35"
              style="display:inline-flex; align-items:center;"
            >
              <path
                d="M533.5 278.4c0-18.5-1.5-37.1-4.7-55.3H272.1v104.8h147c-6.1 33.8-25.7 63.7-54.4 82.7v68h87.7c51.5-47.4 81.1-117.4 81.1-200.2z"
                fill="#4285f4"
              />
              <path
                d="M272.1 544.3c73.4 0 135.3-24.1 180.4-65.7l-87.7-68c-24.4 16.6-55.9 26-92.6 26-71 0-131.2-47.9-152.8-112.3H28.9v70.1c46.2 91.9 140.3 149.9 243.2 149.9z"
                fill="#34a853"
              />
              <path
                d="M119.3 324.3c-11.4-33.8-11.4-70.4 0-104.2V150H28.9c-38.6 76.9-38.6 167.5 0 244.4l90.4-70.1z"
                fill="#fbbc04"
              />
              <path
                d="M272.1 107.7c38.8-.6 76.3 14 104.4 40.8l77.7-77.7C405 24.6 339.7-.8 272.1 0 169.2 0 75.1 58 28.9 150l90.4 70.1c21.5-64.5 81.8-112.4 152.8-112.4z"
                fill="#ea4335"
              />
            </svg>
          </div>
          <div class="w-4/5 flex items-center justify-center p-3">
            <p class="text-white text-2xl">Sign in with Google</p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
