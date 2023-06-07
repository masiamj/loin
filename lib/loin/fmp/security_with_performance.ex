defmodule Loin.FMP.SecurityWithPerformance do
  @moduledoc """
  Schema for the base security on the platform.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "securities_with_performance" do
    field :address, :string
    field :beta, :float
    field :ceo, :string
    field :change_percent, :float
    field :change_price, :float
    field :cik, :string
    field :city, :string
    field :country, :string
    field :currency, :string
    field :cusip, :string
    field :day_1_performance, :float
    field :day_5_performance, :float
    field :day_200_sma, :float
    field :day_50_sma, :float
    field :day_high, :float
    field :day_low, :float
    field :dcf_difference, :string
    field :dcf, :string
    field :description, :string
    field :eps, :float
    field :exchange_short_name, :string
    field :exchange, :string
    field :founded, :string
    field :full_time_employees, :integer
    field :headquarters, :string
    field :image, :string
    field :industry, :string
    field :ipo_date, :string
    field :is_actively_trading, :boolean
    field :is_adr, :boolean
    field :is_etf, :boolean
    field :is_fund, :boolean
    field :isin, :string
    field :last_dividend, :float
    field :market_cap, :integer
    field :max_performance, :float
    field :month_1_performance, :float
    field :month_3_performance, :float
    field :month_6_performance, :float
    field :name, :string
    field :open, :float
    field :pe, :float
    field :previous_close, :float
    field :price, :float
    field :sector, :string
    field :shares_outstanding, :integer
    field :state, :string
    field :sub_sector, :string
    field :symbol, :string
    field :type, :string
    field :volume_avg, :integer
    field :volume, :integer
    field :website, :string
    field :year_1_performance, :float
    field :year_3_performance, :float
    field :year_5_performance, :float
    field :year_10_performance, :float
    field :year_high, :float
    field :year_low, :float
    field :ytd_performance, :float
    field :zip, :string

    timestamps()
  end

  @doc false
  def changeset(fmp_security, attrs) do
    fmp_security
    |> cast(attrs, [
      :address,
      :beta,
      :ceo,
      :change_percent,
      :change_price,
      :cik,
      :city,
      :country,
      :currency,
      :cusip,
      :day_1_performance,
      :day_5_performance,
      :day_200_sma,
      :day_50_sma,
      :day_high,
      :day_low,
      :dcf_difference,
      :dcf,
      :description,
      :eps,
      :exchange_short_name,
      :exchange,
      :founded,
      :full_time_employees,
      :headquarters,
      :image,
      :industry,
      :ipo_date,
      :is_actively_trading,
      :is_adr,
      :is_etf,
      :is_fund,
      :isin,
      :last_dividend,
      :market_cap,
      :max_performance,
      :month_1_performance,
      :month_3_performance,
      :month_6_performance,
      :name,
      :open,
      :pe,
      :previous_close,
      :price,
      :sector,
      :shares_outstanding,
      :state,
      :sub_sector,
      :symbol,
      :type,
      :volume_avg,
      :volume,
      :website,
      :year_1_performance,
      :year_3_performance,
      :year_5_performance,
      :year_10_performance,
      :year_high,
      :year_low,
      :ytd_performance,
      :zip
    ])
    |> validate_required([
      :symbol
    ])
    |> unique_constraint([:symbol])
  end
end
