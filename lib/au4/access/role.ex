defmodule Au4.Access.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :string


    many_to_many :permissions, Au4.Access.Permission, join_through: Au4.Access.RolePermission, on_replace: :delete
    many_to_many :users, Au4.Account.User, join_through: Au4.Access.RoleUser, on_replace: :delete


    timestamps(type: :utc_datetime)
  end



  @doc false

  def changeset(role, attrs, permissions \\ nil) do
    changeset =
      role
      |> cast(attrs, [:name])
      |> validate_required([:name])

    # Only call put_assoc if permissions were explicitly passed
    if permissions do
      put_assoc(changeset, :permissions, permissions)
    else
      changeset
    end
  end
end
