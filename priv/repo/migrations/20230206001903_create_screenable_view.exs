defmodule Loin.Repo.Migrations.CreateScreenableView do
  use Ecto.Migration
  use Familiar

  def change do
    create_view("screener", version: 1)
  end
end
