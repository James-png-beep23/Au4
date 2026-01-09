defmodule Au4.Context.Floor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "floors" do
    field :name, :string

    belongs_to :apartment, Au4.Context.Apartment
    has_many :units, Au4.Context.Unit, on_delete: :delete_all, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(floor, attrs) do
    floor
    |> cast(attrs, [:name, :apartment_id])
    |> validate_required([:name])
    |> cast_assoc(:units, with: &Au4.Context.Unit.changeset/2)
  end
end
