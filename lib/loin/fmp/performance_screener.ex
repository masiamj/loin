defmodule Loin.FMP.PerformanceScreener do
  @moduledoc """
  Schema for the initial implementation of a performance screener Postgres VIEW.
  """
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {
    Flop.Schema,
    default_order: %{
      order_by: [:market_cap],
      order_directions: [:desc]
    },
    filterable: [
      :change_percent,
      :change_price,
      :day_5_performance,
      :industry,
      :market_cap,
      :month_1_performance,
      :month_3_performance,
      :month_6_performance,
      :pe,
      :price,
      :sector,
      :securities_with_performance_day_200_sma,
      :securities_with_performance_day_50_sma,
      :symbol,
      :trend_change,
      :trend,
      :volume,
      :year_1_performance,
      :year_10_performance,
      :year_3_performance,
      :year_5_performance,
      :ytd_performance
    ],
    sortable: [
      :change_percent,
      :change_price,
      :day_5_performance,
      :industry,
      :market_cap,
      :month_1_performance,
      :month_3_performance,
      :month_6_performance,
      :pe,
      :price,
      :sector,
      :securities_with_performance_day_200_sma,
      :securities_with_performance_day_50_sma,
      :symbol,
      :trend_change,
      :trend,
      :volume,
      :year_1_performance,
      :year_10_performance,
      :year_3_performance,
      :year_5_performance,
      :ytd_performance
    ]
  }
  schema "performance_screener" do
    field :address, :string
    field :beta, :float
    field :ceo, :string
    field :change_percent, :float
    field :change_price, :float
    field :cik, :string
    field :city, :string
    field :close_above_day_200_sma, :boolean
    field :close_above_day_50_sma, :boolean
    field :country, :string
    field :currency, :string
    field :cusip, :string
    field :daily_trends_close, :float
    field :daily_trends_date, :date
    field :daily_trends_day_200_sma, :float
    field :daily_trends_day_50_sma, :float
    field :daily_trends_id, :string
    field :daily_trends_inserted_at, :utc_datetime_usec
    field :daily_trends_is_valid, :boolean
    field :daily_trends_near_day_100_high, :boolean
    field :daily_trends_near_day_20_high, :boolean
    field :daily_trends_near_day_50_high, :boolean
    field :daily_trends_previous_close, :float
    field :daily_trends_symbol, :string
    field :daily_trends_updated_at, :utc_datetime_usec
    field :daily_trends_volume, :float
    field :day_1_performance, :float
    field :day_5_performance, :float
    field :day_50_sma_above_day_200_sma, :boolean
    field :dcf_difference, :float
    field :dcf, :float
    field :description, :string
    field :eps, :float
    field :exchange_short_name, :string
    field :exchange, :string
    field :full_time_employees, :integer
    field :image, :string
    field :industry, :string
    field :ipo_date, :string
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
    field :pe, :float
    field :previous_close_above_day_200_sma, :boolean
    field :previous_close_above_day_50_sma, :boolean
    field :previous_day_200_sma, :float
    field :previous_day_50_sma_above_day_200_sma, :boolean
    field :previous_day_50_sma, :float
    field :previous_trend, :string
    field :previous_truthy_flags_count, :integer
    field :price, :float
    field :sector, :string
    field :securities_with_performance_day_200_sma, :float
    field :securities_with_performance_day_50_sma, :float
    field :securities_with_performance_day_high, :float
    field :securities_with_performance_day_low, :float
    field :securities_with_performance_id, :string
    field :securities_with_performance_inserted_at, :utc_datetime_usec
    field :securities_with_performance_open, :float
    field :securities_with_performance_previous_close, :float
    field :securities_with_performance_symbol, :string
    field :securities_with_performance_year_high, :float
    field :securities_with_performance_year_low, :float
    field :shares_outstanding, :integer
    field :state, :string
    field :symbol, :string
    field :trend_change, :string
    field :trend, :string
    field :truthy_flags_count, :integer
    field :volume_avg, :float
    field :volume, :integer
    field :website, :string
    field :year_1_performance, :float
    field :year_10_performance, :float
    field :year_3_performance, :float
    field :year_5_performance, :float
    field :ytd_performance, :float
    field :zip_code, :string
  end
end
