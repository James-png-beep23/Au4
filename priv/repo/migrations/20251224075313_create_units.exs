defmodule Au4.Repo.Migrations.CreateUnits do
  use Ecto.Migration

  def change do
    create table(:units) do
      add :name, :string
      add :description, :string
      # add :floor_id, references(:floor, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
