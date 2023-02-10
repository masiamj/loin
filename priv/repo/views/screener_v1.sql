SELECT
  daily_trends.*,

  fmp_securities.id as id,
  fmp_securities.ceo as ceo,
  fmp_securities.change as change_value,
  fmp_securities.change_percent as change_percent,
  fmp_securities.cik as cik,
  fmp_securities.city as city,
  fmp_securities.country as country,
  fmp_securities.currency as currency,
  fmp_securities.description as description,
  fmp_securities.eps as eps,
  fmp_securities.exchange as exchange,
  fmp_securities.exchange_short_name as exchange_short_name,
  fmp_securities.full_time_employees as full_time_employees,
  fmp_securities.id as fmp_securities_id,
  fmp_securities.image as image,
  fmp_securities.industry as industry,
  fmp_securities.inserted_at as fmp_securities_inserted_at,
  fmp_securities.ipo_date as ipo_date,
  fmp_securities.is_etf as is_etf,
  fmp_securities.last_dividend as last_dividend,
  fmp_securities.market_cap as market_cap,
  fmp_securities.name as name,
  fmp_securities.pe as pe,
  fmp_securities.price as price,
  fmp_securities.sector as sector,
  fmp_securities.state as state,
  fmp_securities.symbol as fmp_securities_symbol,
  fmp_securities.updated_at as fmp_securities_updated_at,
  fmp_securities.volume as volume,
  fmp_securities.volume_avg as volume_avg,
  fmp_securities.website as website,

  ttm_ratios.cash_ratio as cash_ratio_ttm,
  ttm_ratios.current_ratio as current_ratio_ttm,
  ttm_ratios.dividend_yield as dividend_yield_ttm,
  ttm_ratios.earnings_yield as earnings_yield_ttm,
  ttm_ratios.id as ttm_ratios_id,
  ttm_ratios.inserted_at as ttm_ratios_inserted_at,
  ttm_ratios.net_profit_margin as net_profit_margin_ttm,
  ttm_ratios.pe_ratio as pe_ratio_ttm,
  ttm_ratios.peg_ratio as peg_ratio_ttm,
  ttm_ratios.price_to_book_ratio as price_to_book_ratio_ttm,
  ttm_ratios.price_to_sales_ratio as price_to_sales_ratio_ttm,
  ttm_ratios.quick_ratio as quick_ratio_ttm,
  ttm_ratios.return_on_assets as return_on_assets_ttm,
  ttm_ratios.return_on_equity as return_on_equity_ttm,
  ttm_ratios.updated_at as ttm_ratios_updated_at,
  ttm_ratios.symbol as ttm_ratios_symbol
FROM
  fmp_securities
FULL OUTER JOIN
  ttm_ratios
ON
  fmp_securities.symbol = ttm_ratios.symbol
FULL OUTER JOIN
  (SELECT DISTINCT ON(symbol) symbol,
    daily_trends.close as daily_trends_close,
    daily_trends.close_above_day_200_sma as close_above_day_200_sma,
    daily_trends.close_above_day_50_sma as close_above_day_50_sma,
    daily_trends.date as daily_trends_date,
    daily_trends.day_200_sma as day_200_sma,
    daily_trends.day_50_sma as day_50_sma,
    daily_trends.day_50_sma_above_day_200_sma as day_50_sma_above_day_200_sma,
    daily_trends.id as daily_trends_id,
    daily_trends.inserted_at as daily_trends_inserted_at,
    daily_trends.is_valid as daily_trends_is_valid,
    daily_trends.previous_close as daily_trends_previous_close,
    daily_trends.previous_close_above_day_200_sma as previous_close_above_day_200_sma,
    daily_trends.previous_close_above_day_50_sma as previous_close_above_day_50_sma,
    daily_trends.previous_day_200_sma as previous_day_200_sma,
    daily_trends.previous_day_50_sma as previous_day_50_sma,
    daily_trends.previous_day_50_sma_above_day_200_sma as previous_day_50_sma_above_day_200_sma,
    daily_trends.previous_trend as previous_trend,
    daily_trends.previous_truthy_flags_count as previous_truthy_flags_count,
    daily_trends.symbol as daily_trends_symbol,
    daily_trends.trend as trend,
    daily_trends.trend_change as trend_change,
    daily_trends.truthy_flags_count as truthy_flags_count,
    daily_trends.updated_at as daily_trends_updated_at,
    daily_trends.volume as daily_trends_volume
  FROM daily_trends WHERE is_valid = true ORDER BY symbol, date DESC) daily_trends
ON
  fmp_securities.symbol = daily_trends.symbol
;