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
    filterable: [:close, :name], sortable: [:close, :name]
  }
  schema "screener" do
    # daily_trends
    field :close, :float
    field :close_above_day_200_sma, :boolean, default: false
    field :close_above_day_50_sma, :boolean, default: false
    field :daily_trends_date, :date
    field :day_200_sma, :float
    field :day_50_sma, :float
    field :day_50_sma_above_day_200_sma, :boolean, default: false
    field :daily_trends_is_valid, :boolean, default: false
    field :previous_close, :float
    field :previous_close_above_day_200_sma, :boolean, default: false
    field :previous_close_above_day_50_sma, :boolean, default: false
    field :previous_day_200_sma, :float
    field :previous_day_50_sma, :float
    field :previous_day_50_sma_above_day_200_sma, :boolean, default: false
    field :previous_trend, :string
    field :daily_trends_symbol, :string
    field :trend, :string
    field :trend_change, :string

    # fmp_securities
    field :ceo, :string
    field :change_value, :float
    field :change_percent, :float
    field :eps, :float
    field :exchange, :string
    field :exchange_short_name, :string
    field :full_time_employees, :integer
    field :image, :string
    field :industry, :string
    field :ipo_date, :string
    field :is_etf, :boolean, default: false
    field :last_dividend, :float
    field :market_cap, :integer
    field :name, :string
    field :pe, :float
    field :price, :float
    field :sector, :string
    field :fmp_securities_symbol, :string
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
    field :ttm_ratios_symbol, :string

    # timestamps()
  end
end
