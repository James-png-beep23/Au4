defmodule Au4.Context.UserApartment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_apartments" do
    belongs_to :user, Au4.Account.User
    belongs_to :apartment, Au4.Context.Apartment
    belongs_to :unit, Au4.Context.Unit
    belongs_to :floor, Au4.Context.Floor
    belongs_to :role, Au4.Access.Role

  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:user_id, :apartment_id, :floor_id, :unit_id, :role_id])
    |> validate_required([:user_id, :apartment_id])
    # Logic: If role is "tenant", you might want to require a unit_id
    |> validate_unit_if_tenant()
  end

  defp validate_unit_if_tenant(changeset) do
    # You can add custom logic here later to ensure tenants have units
    changeset
  end
end
