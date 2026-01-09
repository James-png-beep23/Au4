defmodule Au4.Repo.Migrations.CreateUserApartment do
  use Ecto.Migration

  def change do
    create table(:user_apartments) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :apartment_id, references(:apartments, on_delete: :delete_all), null: false
      add :floor_id, references(:floors, on_delete: :delete_all), null: false
      add :unit_id, references(:units, on_delete: :delete_all), null: false

    end

  end
end
