defmodule Au4.Access do
  @moduledoc """
  The Access context.
  """

  import Ecto.Query, warn: false
  alias Au4.Repo

  alias Au4.Access.Role
  alias Au4.Account.User
  alias Au4.Access.Permission

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles do
    Repo.all(Role) |> Repo.preload(:permissions)
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id), do: Repo.get!(Role, id) |> Repo.preload(:permissions)

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
# def create_role(attrs \\ %{}) do
#   # 1. Get the list of IDs from the form
#   permission_ids = Map.get(attrs, "permission_ids", [])

#   # 2. Fetch the actual permission records from the DB
#   permissions = Repo.all(from p in Au4.Access.Permission, where: p.id in ^permission_ids)

#   %Role{}
#   |> Role.changeset(attrs)
#   |> Ecto.Changeset.put_assoc(:permissions, permissions) # This creates the links
#   |> Repo.insert()
# end

def update_role(%Role{} = role, attrs) do
  role
  |> change_role(attrs) # This uses the logic we just fixed!
  |> Repo.update()
end

def create_role(attrs \\ %{}) do
  %Role{}
  |> change_role(attrs) # Consistency is key
  |> Repo.insert()
end

  @doc """
  # Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
# def update_role(%Role{} = role, attrs) do
#   permission_ids = Map.get(attrs, "permission_ids", [])
#   permissions = Repo.all(from p in Au4.Access.Permission, where: p.id in ^permission_ids)

#   role
#   |> Repo.preload(:permissions) # Must preload existing perms before updating assoc
#   |> Role.changeset(attrs)
#   |> Ecto.Changeset.put_assoc(:permissions, permissions)
#   |> Repo.update()
# end


  # def delete_role(%Role{} = role) do
  #   Repo.delete(role)
  # end



def delete_role(%Role{} = role) do
  Repo.transaction(fn ->
    from(rp in Au4.Access.RolePermission, where: rp.role_id == ^role.id)
    |> Repo.delete_all()

    Repo.delete!(role)
  end)
  # This now returns {:ok, %Role{}} which matches your LiveView case {:ok, _}
end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{data: %Role{}}

  """

def change_role(%Role{} = role, attrs \\ %{}) do
  role = Repo.preload(role, :permissions)

  # Use your helper function to handle the ID -> Struct conversion
  # This handles the empty strings and string-to-integer conversion automatically
  permissions =
    if Map.has_key?(attrs, "permission_ids") or Map.has_key?(attrs, :permission_ids) do
      get_permissions_by_ids(attrs["permission_ids"] || attrs[:permission_ids])
    else
      role.permissions
    end

  Role.changeset(role, attrs, permissions)
end

defp get_permissions_by_ids(nil), do: []
defp get_permissions_by_ids(ids) when is_list(ids) do
  ids =
    ids
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn
      id when is_binary(id) -> String.to_integer(id)
      id when is_integer(id) -> id
    end)

  Repo.all(from p in Permission, where: p.id in ^ids)
end
defp get_permissions_by_ids(_), do: []


def list_users_with_roles do
  User
  |> Repo.all()
  |> Repo.preload(:roles)
end

def update_user_roles(user, role_ids) do
  roles = Repo.all(from r in Role, where: r.id in ^role_ids)

  user
  |> Repo.preload(:roles)
  |> Ecto.Changeset.change()
  |> Ecto.Changeset.put_assoc(:roles, roles)
  |> Repo.update()
end






  def list_permissions do
    Repo.all(Permission) |> Repo.preload(:roles)
  end

  def get_permission!(id), do: Repo.get!(Permission, id) |> Repo.preload(:roles)


  def create_permission(attrs \\ %{}) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end


  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.update()
  end

  # def delete_permission(%Permission{} = permission) do
  #   Repo.delete(permission)
  # end

def delete_permission(%Permission{} = permission) do
  Repo.transaction(fn ->
    from(rp in Au4.Access.RolePermission, where: rp.permission_id == ^permission.id)
    |> Repo.delete_all()

    Repo.delete!(permission)
  end)
  # This now returns {:ok, %Permission{}}
end


  def change_permission(%Permission{} = permission, attrs \\ %{}) do
    Permission.changeset(permission, attrs)
  end







@spec get_role_by_name(any()) ::
        nil | [%{optional(atom()) => any()}] | %{optional(atom()) => any()}
def get_role_by_name(name) do
    Repo.get_by(Role, name: name) |> Repo.preload(:permissions)
  end
end
