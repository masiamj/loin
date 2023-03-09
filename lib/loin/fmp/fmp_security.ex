defmodule Loin.FMP.FMPSecurity do
  @moduledoc """
  Schema for the base security on the platform.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fmp_securities" do
    field :ceo, :string
    field :change, :float
    field :change_percent, :float
    field :cik, :string
    field :city, :string
    field :country, :string
    field :currency, :string
    field :day_200_sma, :float
    field :day_50_sma, :float
    field :day_high, :float
    field :day_low, :float
    field :description, :string
    field :eps, :float
    field :exchange, :string
    field :exchange_short_name, :string
    field :full_time_employees, :integer
    field :image, :string
    field :industry, :string
    field :ipo_date, :string
    field :is_active, :boolean, default: true
    field :is_etf, :boolean, default: false
    field :last_dividend, :float
    field :market_cap, :integer
    field :name, :string
    field :open, :float
    field :pe, :float
    field :previous_close, :float
    field :price, :float
    field :sector, :string
    field :state, :string
    field :symbol, :string
    field :volume, :integer
    field :volume_avg, :integer
    field :website, :string
    field :year_high, :float
    field :year_low, :float

    timestamps()
  end

  @doc false
  def changeset(fmp_security, attrs) do
    fmp_security
    |> cast(attrs, [
      :ceo,
      :change,
      :change_percent,
      :cik,
      :city,
      :country,
      :currency,
      :description,
      :eps,
      :exchange,
      :exchange_short_name,
      :full_time_employees,
      :image,
      :industry,
      :ipo_date,
      :is_etf,
      :last_dividend,
      :market_cap,
      :name,
      :pe,
      :price,
      :sector,
      :state,
      :symbol,
      :volume,
      :volume_avg,
      :website
    ])
    |> validate_required([
      :cik,
      :country,
      :currency,
      :exchange,
      :exchange_short_name,
      :industry,
      :is_etf,
      :market_cap,
      :name,
      :sector,
      :symbol
    ])
    |> unique_constraint([:symbol])
  end
end
