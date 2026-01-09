defmodule Au4.Repo.Migrations.AlterApartment do
  use Ecto.Migration

  def change do
    alter table(:apartments) do
      add :floor_id, references(:floors, on_delete: :delete_all)
    end

    alter table(:floors) do
      add :apartment_id, references(:apartments, on_delete: :delete_all)
    end


    alter table(:units) do
      add :floor_id, references(:floors, on_delete: :delete_all)
    end

  end
end
