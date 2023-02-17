defmodule Loin.Accounts.IdentitySecurity do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "identity_securities" do
    field :symbol, :string
    belongs_to :identity, Loin.Accounts.Identity

    timestamps()
  end

  @doc false
  def changeset(identity_security, attrs) do
    identity_security
    |> cast(attrs, [:identity_id, :symbol])
    |> validate_required([:identity_id, :symbol])
    |> unique_constraint([:identity_id, :symbol],
      message: "That item is already in your watchlist"
    )
  end
end
