defmodule Loin.Repo.Migrations.AddSecuritiesWithPerformance do
  use Ecto.Migration

  def change do
    create table(:securities_with_performance, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :address, :string
      add :beta, :float
      add :ceo, :string
      add :change_percent, :float
      add :change_price, :float
      add :cik, :string
      add :city, :string
      add :country, :string
      add :currency, :string
      add :cusip, :string
      add :day_1_performance, :float
      add :day_5_performance, :float
      add :day_200_sma, :float
      add :day_50_sma, :float
      add :day_high, :float
      add :day_low, :float
      add :dcf_difference, :string
      add :dcf, :string
      add :description, :text
      add :eps, :float
      add :exchange_short_name, :string
      add :exchange, :string
      add :full_time_employees, :integer
      add :image, :string
      add :industry, :string
      add :ipo_date, :string
      add :is_actively_trading, :boolean
      add :is_adr, :boolean
      add :is_etf, :boolean
      add :is_fund, :boolean
      add :isin, :string
      add :last_dividend, :float
      add :market_cap, :bigint
      add :max_performance, :float
      add :month_1_performance, :float
      add :month_3_performance, :float
      add :month_6_performance, :float
      add :name, :string
      add :open, :float
      add :pe, :float
      add :previous_close, :float
      add :price, :float
      add :sector, :string
      add :shares_outstanding, :bigint
      add :state, :string
      add :symbol, :string
      add :volume_avg, :bigint
      add :volume, :bigint
      add :website, :string
      add :year_1_performance, :float
      add :year_3_performance, :float
      add :year_5_performance, :float
      add :year_10_performance, :float
      add :year_high, :float
      add :year_low, :float
      add :ytd_performance, :float
      add :zip, :string

      timestamps(autogenerate: {DateTime, :utc_now, []}, type: :timestamptz)
    end

    create unique_index(:securities_with_performance, [:symbol])
  end
end
