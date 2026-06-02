defmodule Au4.Repo.Migrations.PaymentAll do
  use Ecto.Migration

  def change do
    create table(:charges) do
      add :unit_id, references(:units)
      add :user_id, references(:users)

      add :amount, :decimal, precision: 12, scale: 2
      add :status, :string, default: "pending"
      add :due_date, :date

      timestamps()
    end

  end
end
