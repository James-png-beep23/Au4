defmodule Au4.Repo.Migrations.CreateCharges do
  use Ecto.Migration

  def change do
    create table(:bills) do
      add :water_meter_reading, :decimal, precision: 10, scale: 2
      add :waste_collction_charges, :decimal, precision: 10, scale: 2
      add :other_charges, :decimal, precision: 10, scale: 2

      add :unit_id, references(:units, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end


    create table(:requests) do
      add :request_type, :string
      add :description, :text
      add :requested_by, :string
      add :priority, :string
      add :assigned_to, :string
      add :due_date, :utc_datetime
      add :available_date, :utc_datetime
      add :status, :string, default: "pending"
      
      add :unit_id, references(:units, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
