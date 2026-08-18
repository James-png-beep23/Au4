defmodule Au4.Repo.Migrations.AlterUnit2 do
  use Ecto.Migration

  def change do
    alter table(:units) do
      modify :price, :integer, default: 0
    end

  end
end
