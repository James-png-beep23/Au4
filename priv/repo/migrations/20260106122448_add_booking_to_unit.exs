defmodule Au4.Repo.Migrations.AddBookingToUnit do
  use Ecto.Migration

  def change do
    alter table(:units) do
    add :booking, :string, null: true
    end

  end
end
