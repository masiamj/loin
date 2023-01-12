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
  attr :title, :string, required: true, doc: "the title of the card"
  attr :updated_at, :string, default: nil

  slot :inner_block, required: true

  def generic(assigns) do
    ~H"""
    <div class="bg-white p-3 rounded-md border border-gray-200">
      <div class="flex flex-row items-center space-x-2 mb-2">
        <p class="font-bold text-sm"><%= @title %></p>
        <p :if={is_binary(@updated_at)} class="text-xs text-gray-400 italic tracking-tight">
          Updated <%= @updated_at %>
        </p>
      </div>
      <div>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
