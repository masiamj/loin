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

  slot :inner_block, required: true

  def generic(assigns) do
    ~H"""
    <div class="bg-white p-3 rounded-md border border-gray-200">
      <p class="font-bold text-sm mb-2"><%= @title %></p>
      <div>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
