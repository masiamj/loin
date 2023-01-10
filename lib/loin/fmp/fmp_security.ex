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
    field :country, :string
    field :currency, :string
    field :description, :string
    field :exchange, :string
    field :exchange_short_name, :string
    field :full_time_employees, :integer
    field :image, :string
    field :industry, :string
    field :is_etf, :boolean, default: false
    field :market_cap, :integer
    field :name, :string
    field :sector, :string
    field :symbol, :string
    field :website, :string

    timestamps()
  end

  @doc false
  def changeset(fmp_security, attrs) do
    fmp_security
    |> cast(attrs, [
      :country,
      :currency,
      :description,
      :exchange,
      :exchange_short_name,
      :full_time_employees,
      :image,
      :industry,
      :is_etf,
      :market_cap,
      :name,
      :sector,
      :symbol,
      :website
    ])
    |> validate_required([
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
