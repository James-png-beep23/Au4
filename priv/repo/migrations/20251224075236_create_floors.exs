defmodule Au4.Repo.Migrations.CreateFloors do
  use Ecto.Migration

  def change do
    create table(:floors) do
      add :name, :string
      # add :apartment_id, references(:apartments, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
