defmodule Loin.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:identities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :first_name, :string
      add :image_url, :string
      add :last_name, :string

      timestamps(autogenerate: {DateTime, :utc_now, []}, type: :timestamptz)
    end

    create unique_index(:identities, [:email])
  end
end
