defmodule Loin.Repo.Migrations.AddFunWithFlagsTogglesTable do
  use Ecto.Migration

  @table_name :fun_with_flags_toggles

  def up do
    create table(@table_name, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :flag_name, :string, null: false
      add :gate_type, :string, null: false
      add :target, :string, null: false
      add :enabled, :boolean, null: false
    end

    create index(
             @table_name,
             [:flag_name, :gate_type, :target],
             unique: true,
             name: "fwf_flag_name_gate_target_idx"
           )
  end

  def down do
    drop table(@table_name)
  end
end
