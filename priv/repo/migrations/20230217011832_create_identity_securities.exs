defmodule Loin.Repo.Migrations.CreateIdentitySecurities do
  use Ecto.Migration

  def change do
    create table(:identity_securities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string

      add :identity_id, references(:identities, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(autogenerate: {DateTime, :utc_now, []}, type: :timestamptz)
    end

    create index(:identity_securities, [:symbol])
    create index(:identity_securities, [:identity_id])
    create unique_index(:identity_securities, [:identity_id, :symbol])
  end
end
