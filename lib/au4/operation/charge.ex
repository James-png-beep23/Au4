defmodule Au4.Operation.Charge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bills" do
    field :water_meter_reading, :decimal
    field :waste_collction_charges
    field :other_charges, :decimal

    belongs_to :unit, Au4.Context.Unit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bill, attrs) do
    bill
    |> cast(attrs, [:water_meter_reading, :waste_collction_charges, :other_charges])
    |> validate_required([:water_meter_reading, :waste_collction_charges, :other_charges])
  end
end
