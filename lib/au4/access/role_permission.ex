defmodule Au4.Access.RolePermission do
  use Ecto.Schema

  @primary_key false
  schema "role_permissions" do
    belongs_to :role, Au4.Access.Role
    belongs_to :permission, Au4.Access.Permission
    
  end
end
