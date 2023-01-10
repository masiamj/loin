defmodule Loin.Repo.Migrations.CreateFmpSecurities do
  use Ecto.Migration

  def change do
    create table(:fmp_securities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :country, :string
      add :currency, :string
      add :description, :text
      add :exchange, :string
      add :exchange_short_name, :string
      add :full_time_employees, :integer
      add :image, :string
      add :industry, :string
      add :is_etf, :boolean, default: false, null: false
      add :market_cap, :bigint
      add :name, :string
      add :sector, :string
      add :symbol, :string
      add :website, :string

      timestamps(autogenerate: {DateTime, :utc_now, []}, type: :timestamptz)
    end

    create unique_index(:fmp_securities, [:symbol])
  end
end
