defmodule Loin.Repo.Migrations.CreateScreenablePerformanceView do
  use Ecto.Migration
  use Familiar

  def change do
    create_view("performance_screener", version: 1)
  end
end
