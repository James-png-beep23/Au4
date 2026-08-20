defmodule Au4.Repo.Migrations.AlterUnitAddCharges do
  use Ecto.Migration

  def change do
    alter table(:units) do
     add :charges, :map


  end

  end
end
