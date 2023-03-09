defmodule Loin.FMP.Screener do
  @moduledoc """
  Schema for the initial implementation of a screener Postgres VIEW.
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
      :symbol,

      # daily_trends
      :daily_trends_close,
      :close_above_day_200_sma,
      :close_above_day_50_sma,
      :daily_trends_date,
      :daily_trends_day_200_sma,
      :daily_trends_day_50_sma,
      :day_50_sma_above_day_200_sma,
      :daily_trends_id,
      :daily_trends_inserted_at,
      :daily_trends_is_valid,
      :daily_trends_previous_close,
      :previous_close_above_day_200_sma,
      :previous_close_above_day_50_sma,
      :previous_day_200_sma,
      :previous_day_50_sma,
      :previous_day_50_sma_above_day_200_sma,
      :previous_trend,
      :previous_truthy_flags_count,
      :daily_trends_symbol,
      :trend,
      :trend_change,
      :truthy_flags_count,
      :daily_trends_updated_at,
      :daily_trends_volume,

      # fmp_securities
      :ceo,
      :change_percent,
      :change_value,
      :cik,
      :city,
      :country,
      :currency,
      :description,
      :eps,
      :exchange_short_name,
      :exchange,
      :fmp_securities_day_200_sma,
      :fmp_securities_day_50_sma,
      :fmp_securities_day_high,
      :fmp_securities_day_low,
      :fmp_securities_id,
      :fmp_securities_open,
      :fmp_securities_previous_close,
      :fmp_securities_symbol,
      :fmp_securities_updated_at,
      :fmp_securities_year_high,
      :fmp_securities_year_low,
      :full_time_employees,
      :image,
      :industry,
      :fmp_securities_inserted_at,
      :ipo_date,
      :is_etf,
      :last_dividend,
      :market_cap,
      :name,
      :pe,
      :price,
      :sector,
      :state,
      :volume_avg,
      :volume,
      :website,

      # ttm_ratios
      :cash_ratio_ttm,
      :current_ratio_ttm,
      :dividend_yield_ttm,
      :earnings_yield_ttm,
      :net_profit_margin_ttm,
      :pe_ratio_ttm,
      :peg_ratio_ttm,
      :price_to_book_ratio_ttm,
      :price_to_sales_ratio_ttm,
      :quick_ratio_ttm,
      :return_on_assets_ttm,
      :return_on_equity_ttm,
      :ttm_ratios_id,
      :ttm_ratios_inserted_at,
      :ttm_ratios_symbol,
      :ttm_ratios_updated_at
    ],
    sortable: [
      :symbol,

      # daily_trends
      :daily_trends_close,
      :close_above_day_200_sma,
      :close_above_day_50_sma,
      :daily_trends_date,
      :daily_trends_day_200_sma,
      :daily_trends_day_50_sma,
      :day_50_sma_above_day_200_sma,
      :daily_trends_id,
      :daily_trends_inserted_at,
      :daily_trends_is_valid,
      :daily_trends_previous_close,
      :previous_close_above_day_200_sma,
      :previous_close_above_day_50_sma,
      :previous_day_200_sma,
      :previous_day_50_sma,
      :previous_day_50_sma_above_day_200_sma,
      :previous_trend,
      :previous_truthy_flags_count,
      :daily_trends_symbol,
      :trend,
      :trend_change,
      :truthy_flags_count,
      :daily_trends_updated_at,
      :daily_trends_volume,

      # fmp_securities
      :ceo,
      :change_percent,
      :change_value,
      :cik,
      :city,
      :country,
      :currency,
      :description,
      :eps,
      :exchange_short_name,
      :exchange,
      :fmp_securities_day_200_sma,
      :fmp_securities_day_50_sma,
      :fmp_securities_day_high,
      :fmp_securities_day_low,
      :fmp_securities_id,
      :fmp_securities_open,
      :fmp_securities_previous_close,
      :fmp_securities_symbol,
      :fmp_securities_updated_at,
      :fmp_securities_year_high,
      :fmp_securities_year_low,
      :full_time_employees,
      :image,
      :industry,
      :fmp_securities_inserted_at,
      :ipo_date,
      :is_etf,
      :last_dividend,
      :market_cap,
      :name,
      :pe,
      :price,
      :sector,
      :state,
      :volume_avg,
      :volume,
      :website,

      # ttm_ratios
      :cash_ratio_ttm,
      :current_ratio_ttm,
      :dividend_yield_ttm,
      :earnings_yield_ttm,
      :net_profit_margin_ttm,
      :pe_ratio_ttm,
      :peg_ratio_ttm,
      :price_to_book_ratio_ttm,
      :price_to_sales_ratio_ttm,
      :quick_ratio_ttm,
      :return_on_assets_ttm,
      :return_on_equity_ttm,
      :ttm_ratios_id,
      :ttm_ratios_inserted_at,
      :ttm_ratios_symbol,
      :ttm_ratios_updated_at
    ]
  }
  schema "screener" do
    field :symbol, :string

    # daily_trends
    field :close_above_day_200_sma, :boolean, default: false
    field :close_above_day_50_sma, :boolean, default: false
    field :daily_trends_close, :float
    field :daily_trends_date, :date
    field :daily_trends_id, :string
    field :daily_trends_inserted_at, :utc_datetime_usec
    field :daily_trends_is_valid, :boolean, default: false
    field :daily_trends_symbol, :string
    field :daily_trends_updated_at, :utc_datetime_usec
    field :daily_trends_volume, :float
    field :daily_trends_day_200_sma, :float
    field :day_50_sma_above_day_200_sma, :boolean, default: false
    field :daily_trends_day_50_sma, :float
    field :previous_close_above_day_200_sma, :boolean, default: false
    field :previous_close_above_day_50_sma, :boolean, default: false
    field :daily_trends_previous_close, :float
    field :previous_day_200_sma, :float
    field :previous_day_50_sma_above_day_200_sma, :boolean, default: false
    field :previous_day_50_sma, :float
    field :previous_trend, :string
    field :previous_truthy_flags_count, :integer
    field :trend_change, :string
    field :trend, :string
    field :truthy_flags_count, :integer

    # fmp_securities
    field :ceo, :string
    field :change_percent, :float
    field :change_value, :float
    field :cik, :string
    field :city, :string
    field :country, :string
    field :currency, :string
    field :description, :string
    field :eps, :float
    field :exchange_short_name, :string
    field :exchange, :string
    field :fmp_securities_day_200_sma, :float
    field :fmp_securities_day_50_sma, :float
    field :fmp_securities_day_high, :float
    field :fmp_securities_day_low, :float
    field :fmp_securities_id, :string
    field :fmp_securities_open, :float
    field :fmp_securities_previous_close, :float
    field :fmp_securities_symbol, :string
    field :fmp_securities_updated_at, :utc_datetime_usec
    field :fmp_securities_year_high, :float
    field :fmp_securities_year_low, :float
    field :full_time_employees, :integer
    field :image, :string
    field :industry, :string
    field :fmp_securities_inserted_at, :utc_datetime_usec
    field :ipo_date, :string
    field :is_active, :boolean, default: true
    field :is_etf, :boolean, default: false
    field :last_dividend, :float
    field :market_cap, :integer
    field :name, :string
    field :pe, :float
    field :price, :float
    field :sector, :string
    field :state, :string
    field :volume_avg, :integer
    field :volume, :integer
    field :website, :string

    # ttm_ratios
    field :cash_ratio_ttm, :float
    field :current_ratio_ttm, :float
    field :dividend_yield_ttm, :float
    field :earnings_yield_ttm, :float
    field :net_profit_margin_ttm, :float
    field :pe_ratio_ttm, :float
    field :peg_ratio_ttm, :float
    field :price_to_book_ratio_ttm, :float
    field :price_to_sales_ratio_ttm, :float
    field :quick_ratio_ttm, :float
    field :return_on_assets_ttm, :float
    field :return_on_equity_ttm, :float
    field :ttm_ratios_id, :string
    field :ttm_ratios_inserted_at, :utc_datetime_usec
    field :ttm_ratios_symbol, :string
    field :ttm_ratios_updated_at, :utc_datetime_usec
  end
end
