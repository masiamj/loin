defmodule Loin.Repo.Migrations.AddFMPSecuritiesActivity do
  use Ecto.Migration

  def change do
    alter table(:fmp_securities) do
      add :is_active, :boolean, default: true
    end

    create index(:fmp_securities, [:is_active])
  end
end
