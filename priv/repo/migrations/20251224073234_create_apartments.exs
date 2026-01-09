defmodule Au4.Repo.Migrations.CreateApartments do
  use Ecto.Migration

  def change do
    create table(:apartments) do
      add :name, :string
      add :location, :string
      # add :floor_id, references(:floors, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:apartments, :name)
  end
end
