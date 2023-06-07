defmodule Loin.Repo.Migrations.AddDailyTrendHighFields do
  use Ecto.Migration

  def change do
    alter table(:daily_trends) do
      add :near_day_20_high, :boolean, default: false
      add :near_day_50_high, :boolean, default: false
      add :near_day_100_high, :boolean, default: false
    end
  end
end
