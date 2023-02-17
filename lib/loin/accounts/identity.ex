defmodule Loin.Accounts.Identity do
  @moduledoc """
  Schema for an identity.
  """

  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "identities" do
    field :email, :string
    field :first_name, :string
    field :image_url, :string
    field :last_name, :string
    has_many :watchlist_securities, Loin.Accounts.IdentitySecurity

    timestamps()
  end

  @doc """
  A changeset to update an identity.
  """
  def changeset(identity, attrs) do
    identity
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name], message: "Required")
  end

  @doc """
  A changeset to create an identity.
  """
  def registration_changeset(identity, attrs) do
    identity
    |> cast(attrs, [:email, :first_name, :image_url, :last_name])
    |> validate_required([:email, :first_name, :last_name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "Enter a valid email")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Loin.Repo,
      message: "An account with that email already exists"
    )
    |> unique_constraint(:email, message: "An account with that email already exists")
  end
end
