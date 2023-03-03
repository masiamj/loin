defmodule LoinWeb.Cards do
  @moduledoc """
  Provides a set of card components.
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
  Renders a simple form.

  ## Examples

      <.simple_form :let={f} for={:user} phx-change="validate" phx-submit="save">
        <.input field={{f, :email}} label="Email"/>
        <.input field={{f, :username}} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :class, :string, default: ""
  attr :more_link, :string, default: nil, required: false
  attr :title, :string, required: true, doc: "the title of the card"
  attr :updated_at, :string, default: nil

  slot :title_block, required: false
  slot :inner_block, required: true

  def generic(assigns) do
    ~H"""
    <div class={"relative bg-white p-3 rounded-md #{@class}"}>
      <div class="flex flex-row items-center justify-between space-x-2 mb-2">
        <div class="flex flex-row items-center gap-4">
          <p class="font-bold text-sm"><%= @title %></p>
          <%= render_slot(@title_block) %>
        </div>
        <.link
          :if={@more_link}
          navigate={@more_link}
          class="px-2 py-1 bg-white hover:bg-gray-100 rounded-lg flex items-center justify-center text-blue-600 hover:text-blue-700 text-xs font-medium"
        >
          More <Heroicons.arrow_top_right_on_square class="h-3 w-3 ml-1 font-bold" />
        </.link>
      </div>
      <div>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
