defmodule Loin.Repo.Migrations.CreateIdentitiesTables do
  use Ecto.Migration

  def change do
    create table(:identities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext, null: false
      add :first_name, :string
      add :image_url, :string
      add :last_name, :string
      timestamps(autogenerate: {DateTime, :utc_now, []}, type: :timestamptz)
    end

    create unique_index(:identities, [:email])

    create table(:identities_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :identity_id, references(:identities, type: :binary_id, on_delete: :delete_all),
        null: false

      add :token, :binary, null: false
      timestamps(autogenerate: {DateTime, :utc_now, []}, type: :timestamptz, updated_at: false)
    end

    create index(:identities_tokens, [:identity_id])
    create unique_index(:identities_tokens, [:token])
  end
end
