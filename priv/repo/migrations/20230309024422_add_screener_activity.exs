defmodule Loin.Repo.Migrations.AddScreenerActivity do
  use Ecto.Migration
  use Familiar

  def change do
    update_view("screener", version: 2, revert: 1)
  end
end
