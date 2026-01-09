defmodule Au4.Repo.Migrations.CreateRoleUsersRelation do
  use Ecto.Migration

  def change do
     create table(:role_user) do
      add :role_id, references(:roles, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:role_user, [:role_id, :user_id])

  end
end
