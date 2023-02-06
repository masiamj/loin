defmodule Loin.Repo.Migrations.CreateTtmRatios do
  use Ecto.Migration

  def change do
    create table(:ttm_ratios, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :cash_ratio, :float
      add :current_ratio, :float
      add :dividend_yield, :float
      add :earnings_yield, :float
      add :net_profit_margin, :float
      add :pe_ratio, :float
      add :peg_ratio, :float
      add :price_to_book_ratio, :float
      add :price_to_sales_ratio, :float
      add :quick_ratio, :float
      add :return_on_assets, :float
      add :return_on_equity, :float
      add :symbol, :string

      timestamps(autogenerate: {DateTime, :utc_now, []}, type: :timestamptz)
    end

    create unique_index(:ttm_ratios, [:symbol])
  end
end
