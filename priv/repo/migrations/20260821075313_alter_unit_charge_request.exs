defmodule Au4.Repo.Migrations.AlterUnitChargeRequest do
  use Ecto.Migration

    def change do
    alter table(:units) do
     remove :charges, :map



  end

  end

end
