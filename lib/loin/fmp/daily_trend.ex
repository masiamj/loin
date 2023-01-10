defmodule Loin.FMP.DailyTrend do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "daily_trends" do
    field :close, :float
    field :close_above_day_200_sma, :boolean, default: false
    field :close_above_day_50_sma, :boolean, default: false
    field :date, :date
    field :day_200_sma, :float
    field :day_50_sma, :float
    field :day_50_sma_above_day_200_sma, :boolean, default: false
    field :is_valid, :boolean, default: false
    field :previous_close, :float
    field :previous_close_above_day_200_sma, :boolean, default: false
    field :previous_close_above_day_50_sma, :boolean, default: false
    field :previous_day_200_sma, :float
    field :previous_day_50_sma, :float
    field :previous_day_50_sma_above_day_200_sma, :boolean, default: false
    field :previous_trend, :string
    field :previous_truthy_flags_count, :integer
    field :symbol, :string
    field :trend, :string
    field :trend_change, :string
    field :truthy_flags_count, :integer
    field :volume, :float

    timestamps()
  end

  @doc false
  def changeset(daily_trend, attrs) do
    daily_trend
    |> cast(attrs, [
      :close,
      :close_above_day_200_sma,
      :close_above_day_50_sma,
      :date,
      :day_200_sma,
      :day_50_sma,
      :day_50_sma_above_day_200_sma,
      :is_valid,
      :previous_close,
      :previous_close_above_day_200_sma,
      :previous_close_above_day_50_sma,
      :previous_day_200_sma,
      :previous_day_50_sma,
      :previous_day_50_sma_above_day_200_sma,
      :previous_trend,
      :previous_truthy_flags_count,
      :symbol,
      :trend,
      :trend_change,
      :truthy_flags_count,
      :volume
    ])
    |> validate_required([
      :close,
      :close_above_day_200_sma,
      :close_above_day_50_sma,
      :date,
      :day_200_sma,
      :day_50_sma,
      :day_50_sma_above_day_200_sma,
      :is_valid,
      :previous_close,
      :previous_close_above_day_200_sma,
      :previous_close_above_day_50_sma,
      :previous_day_200_sma,
      :previous_day_50_sma,
      :previous_day_50_sma_above_day_200_sma,
      :previous_trend,
      :previous_truthy_flags_count,
      :symbol,
      :trend,
      :trend_change,
      :truthy_flags_count,
      :volume
    ])
    |> unique_constraint([:date, :symbol])
  end
end
