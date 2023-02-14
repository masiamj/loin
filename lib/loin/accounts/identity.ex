defmodule Loin.Accounts.Identity do
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

    timestamps()
  end

  @doc false
  def changeset(identity, attrs) do
    identity
    |> cast(attrs, [:first_name, :last_name, :image_url, :email])
    |> validate_required([:first_name, :last_name, :image_url, :email])
    |> unique_constraint(:email, message: "There is already an account with that email")
  end
end
