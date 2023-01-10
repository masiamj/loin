defmodule Loin.Repo.Migrations.CreateDailyTrends do
  use Ecto.Migration

  def change do
    create table(:daily_trends, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :close, :float
      add :close_above_day_200_sma, :boolean, default: false, null: false
      add :close_above_day_50_sma, :boolean, default: false, null: false
      add :date, :date
      add :day_200_sma, :float
      add :day_50_sma, :float
      add :day_50_sma_above_day_200_sma, :boolean, default: false, null: false
      add :is_valid, :boolean, default: false, null: false
      add :previous_close, :float
      add :previous_close_above_day_200_sma, :boolean, default: false, null: false
      add :previous_close_above_day_50_sma, :boolean, default: false, null: false
      add :previous_day_200_sma, :float
      add :previous_day_50_sma, :float
      add :previous_day_50_sma_above_day_200_sma, :boolean, default: false, null: false
      add :previous_trend, :string
      add :previous_truthy_flags_count, :integer
      add :symbol, :string
      add :trend, :string
      add :trend_change, :string
      add :truthy_flags_count, :integer
      add :volume, :float

      timestamps(autogenerate: {DateTime, :utc_now, []}, type: :timestamptz)
    end

    create unique_index(:daily_trends, [:date, :symbol])
  end
end
