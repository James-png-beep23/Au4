defmodule Au4.Repo.Migrations.AlterUnit do
  use Ecto.Migration

  def change do
  alter table(:units) do
    add :requests, :map
    add :price, :decimal

  end
end
end
