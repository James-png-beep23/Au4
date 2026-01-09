defmodule Au4.Repo.Migrations.AlterUserApart do
  use Ecto.Migration

  def change do
    alter table(:user_apartments) do
      remove :floor_id, references(:floors, on_delete: :delete_all), null: false
      remove :unit_id, references(:units, on_delete: :delete_all), null: false
       remove :role_id, references(:roles,  on_delete: :delete_all), null: false
       
      add :floor_id, references(:floors, on_delete: :delete_all), null: true
      add :unit_id, references(:units, on_delete: :delete_all), null: true
       add :role_id, references(:roles,  on_delete: :delete_all), null: true
    end

  end
end
