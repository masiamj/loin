defmodule Loin.FMP.TTMRatio do
  @moduledoc """
  A representation of the ttm_ratio model.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "ttm_ratios" do
    field :cash_ratio, :float
    field :current_ratio, :float
    field :dividend_yield, :float
    field :earnings_yield, :float
    field :net_profit_margin, :float
    field :pe_ratio, :float
    field :peg_ratio, :float
    field :price_to_book_ratio, :float
    field :price_to_sales_ratio, :float
    field :quick_ratio, :float
    field :return_on_assets, :float
    field :return_on_equity, :float
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(ttm_ratio, attrs) do
    ttm_ratio
    |> cast(attrs, [
      :cash_ratio,
      :currnet_ratio,
      :dividend_yield,
      :earnings_yield,
      :net_profit_margin,
      :pe_ratio,
      :peg_ratio,
      :price_to_book_ratio,
      :price_to_sales_ratio,
      :quick_ratio,
      :return_on_assets,
      :return_on_equity,
      :symbol
    ])
    |> validate_required([:symbol])
    |> unique_constraint([:symbol])
  end
end
