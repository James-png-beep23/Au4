defmodule Au4.Repo.Migrations.AlterUserApartment do
  use Ecto.Migration

  def change do
    alter table(:user_apartments) do
      add :role_id, references(:roles,  on_delete: :delete_all), null: false
    end

  end
end
