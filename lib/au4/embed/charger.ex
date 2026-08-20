defmodule Au4.Embed.Charge do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :unit_id, :integer
    field :water_meter_reading, :decimal
    field :waste_collction_charges, :decimal

  end

  def changeset(charges, attrs) do
    charges
    |> cast(attrs, [:unit_id, :water_meter_reading, :waste_collction_charges])
    |> validate_required([:unit_id, :water_meter_reading, :waste_collction_charges])
  end
end
