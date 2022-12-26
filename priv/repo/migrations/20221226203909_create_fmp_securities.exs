defmodule Loin.Repo.Migrations.CreateFmpSecurities do
  use Ecto.Migration

  def change do
    create table(:fmp_securities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text
      add :exchange, :string
      add :exchange_short_name, :string
      add :full_time_employees, :integer
      add :image, :string
      add :in_dow_jones, :boolean, default: false, null: false
      add :in_nasdaq, :boolean, default: false, null: false
      add :in_sp500, :boolean, default: false, null: false
      add :industry, :string
      add :is_etf, :boolean, default: false, null: false
      add :market_cap, :integer
      add :name, :string
      add :sector, :string
      add :symbol, :string
      add :website, :string

      timestamps()

    end

    create unique_index(:fmp_securities, [:symbol])
  end
end
