defmodule Au4.Access.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :name, :string
    field :description, :string

    many_to_many :roles, Au4.Access.Role, join_through: Au4.Access.RolePermission, on_replace: :delete
  

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(permission, attrs, roles \\ []) do
    permission
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> put_assoc(:roles, roles)
  end
end
