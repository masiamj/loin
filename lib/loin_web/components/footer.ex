defmodule LoinWeb.FooterComponents do
  @moduledoc """
  Provides the Footer comopnents.
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
  Renders an authenticated header.
  """
  def footer(assigns) do
    ~H"""
    <div class="relative flex flex-col w-full bg-white px-8 py-4">
      <div class="flex flex-row flex-wrap items-center justify-center gap-2 text-xs">
        <.link href={~p"/"}>
          <img alt="TrendFlares logo" class="h-8" src="/images/trendflares_logo_black.png" />
        </.link>
        <.link
          navigate={~p"/how-it-works"}
          class="relative px-2 py-1 text-gray-500 hover:text-black line-clamp-1"
        >
          How it works
        </.link>
        <.link
          href="https://blog.trendflares.com"
          class="relative px-2 py-1 text-gray-500 hover:text-black line-clamp-1"
        >
          Blog
        </.link>
        <.link
          navigate="https://blog.trendflares.com/privacy"
          class="relative px-2 py-1 text-gray-500 hover:text-black line-clamp-1"
        >
          Privacy
        </.link>
        <.link
          navigate="https://blog.trendflares.com/terms"
          class="relative px-2 py-1 text-gray-500 hover:text-black line-clamp-1"
        >
          Terms of use
        </.link>
      </div>
      <p class="text-gray-500 text-center text-xs w-2/3 mx-auto">
        TrendFlares is an algorithm-based, historical stock price analysis system and trends identified do not guarantee future performance.<br />TrendFlares must not be construed as financial advice or investing advice.
      </p>
    </div>
    """
  end
end
