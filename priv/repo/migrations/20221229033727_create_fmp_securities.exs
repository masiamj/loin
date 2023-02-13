defmodule Loin.Repo.Migrations.CreateFmpSecurities do
  use Ecto.Migration

  def change do
    create table(:fmp_securities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ceo, :string
      add :change, :float
      add :change_percent, :float
      add :cik, :string
      add :city, :string
      add :country, :string
      add :currency, :string
      add :day_200_sma, :float
      add :day_50_sma, :float
      add :day_high, :float
      add :day_low, :float
      add :description, :text
      add :eps, :float
      add :exchange, :string
      add :exchange_short_name, :string
      add :full_time_employees, :integer
      add :image, :string
      add :industry, :string
      add :ipo_date, :string
      add :is_etf, :boolean, default: false, null: false
      add :last_dividend, :float
      add :market_cap, :bigint
      add :name, :string
      add :open, :float
      add :pe, :float
      add :previous_close, :float
      add :price, :float
      add :sector, :string
      add :state, :string
      add :symbol, :string
      add :volume, :integer
      add :volume_avg, :integer
      add :website, :string
      add :year_high, :float
      add :year_low, :float

      timestamps(autogenerate: {DateTime, :utc_now, []}, type: :timestamptz)
    end

    create unique_index(:fmp_securities, [:symbol])
  end
end
