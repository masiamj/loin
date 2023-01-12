defmodule LoinWeb.Cards do
  @moduledoc """
  Provides a set of card components.
  """
  use Phoenix.Component

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
  attr :more_link, :string, default: nil, required: false
  attr :title, :string, required: true, doc: "the title of the card"
  attr :updated_at, :string, default: nil

  slot :inner_block, required: true

  def generic(assigns) do
    ~H"""
    <div>
      <div class="bg-white p-3 rounded-md border border-gray-200">
        <div class="flex flex-row items-center justify-between space-x-2 mb-2">
          <p class="font-bold text-sm"><%= @title %></p>
          <p :if={is_binary(@updated_at)} class="text-xs text-gray-400 italic tracking-tight">
            Updated <%= @updated_at %>
          </p>
          <a
            :if={@more_link}
            class="px-2 py-1 bg-white hover:bg-gray-100 rounded-lg flex items-center justify-center text-blue-600 hover:text-blue-700 text-xs font-medium"
          >
            See more <Heroicons.arrow_top_right_on_square class="h-3 w-3 ml-1 font-bold" />
          </a>
        </div>
        <div>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end
end
