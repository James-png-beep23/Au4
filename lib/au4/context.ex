defmodule Au4.Context do
  @moduledoc """
  The Context context.
  """

  import Ecto.Query, warn: false
  alias Au4.Repo

  alias Au4.Context.Apartment
  alias Au4.Context.UserApartment

  @doc """
  Returns the list of apartments.

  ## Examples

      iex> list_apartments()
      [%Apartment{}, ...]

  """
# def list_apartments do
#   Repo.all(Apartment)
#   |> Repo.preload([:users, user_apartments: [floor: [units: :user]]])
# end
def list_apartments do
  Apartment
  |> Repo.all()
  |> Repo.preload([
    # Only load users who are NOT in units at the top level
    users: from(u in Au4.Account.User,
             join: ua in "user_apartments", on: ua.user_id == u.id,
             where: is_nil(ua.unit_id)),

    # Physical structure
    floors: [units: :user]
  ])
end


  def get_apartment_with_unit_users!(id) do
    Apartment
    |> where(id: ^id)
    |> preload([
      :users,
      floors: [units: [:user]]  # This preloads users within each unit
    ])
    |> Repo.one!()
  end

  @doc """
  Gets a single apartment.

  Raises `Ecto.NoResultsError` if the Apartment does not exist.

  ## Examples

      iex> get_apartment!(123)
      %Apartment{}

      iex> get_apartment!(456)
      ** (Ecto.NoResultsError)

  """
  # def get_apartment!(id), do: Repo.get!(Apartment, id) |> Repo.preload([:users, user_apartments: [floors: [units: :user]]])

  def get_apartment!(id) do
  Apartment
  |> Repo.get!(id)
  |> Repo.preload([
    # This filters Maya out of the top-level apartment list
    users: from(u in Au4.Account.User,
             join: ua in "user_apartments", on: ua.user_id == u.id,
             where: is_nil(ua.unit_id)),

    # This puts Maya exactly where she belongs (inside her unit)
    floors: [units: :user]
  ])
end

  @doc """
  Creates a apartment.

  ## Examples

      iex> create_apartment(%{field: value})
      {:ok, %Apartment{}}

      iex> create_apartment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_apartment(attrs \\ %{}) do
    %Apartment{}
    |> Apartment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a apartment.

  ## Examples

      iex> update_apartment(apartment, %{field: new_value})
      {:ok, %Apartment{}}

      iex> update_apartment(apartment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_apartment(%Apartment{} = apartment, attrs) do
    apartment
    |> Apartment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a apartment.

  ## Examples

      iex> delete_apartment(apartment)
      {:ok, %Apartment{}}

      iex> delete_apartment(apartment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_apartment(%Apartment{} = apartment) do
    Repo.delete(apartment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking apartment changes.

  ## Examples

      iex> change_apartment(apartment)
      %Ecto.Changeset{data: %Apartment{}}

  """
  def change_apartment(%Apartment{} = apartment, attrs \\ %{}) do
    Apartment.changeset(apartment, attrs)
  end

  alias Au4.Context.Floor

  @doc """
  Returns the list of floors.

  ## Examples

      iex> list_floors()
      [%Floor{}, ...]

  """
  def list_floors do
    Repo.all(Floor) |> Repo.preload(:units)
  end

  @doc """
  Gets a single floor.

  Raises `Ecto.NoResultsError` if the Floor does not exist.

  ## Examples

      iex> get_floor!(123)
      %Floor{}

      iex> get_floor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_floor!(id), do: Repo.get!(Floor, id)  |> Repo.preload(:units)

  @doc """
  Creates a floor.

  ## Examples

      iex> create_floor(%{field: value})
      {:ok, %Floor{}}

      iex> create_floor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_floor(attrs \\ %{}) do
    %Floor{}
    |> Floor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a floor.

  ## Examples

      iex> update_floor(floor, %{field: new_value})
      {:ok, %Floor{}}

      iex> update_floor(floor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_floor(%Floor{} = floor, attrs) do
    floor
    |> Floor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a floor.

  ## Examples

      iex> delete_floor(floor)
      {:ok, %Floor{}}

      iex> delete_floor(floor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_floor(%Floor{} = floor) do
    Repo.delete(floor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking floor changes.

  ## Examples

      iex> change_floor(floor)
      %Ecto.Changeset{data: %Floor{}}

  """
  def change_floor(%Floor{} = floor, attrs \\ %{}) do
    Floor.changeset(floor, attrs)
  end

  alias Au4.Context.Unit

  @doc """
  Returns the list of units.

  ## Examples

      iex> list_units()
      [%Unit{}, ...]

  """
  def list_units do
    Repo.all(Unit) |> Repo.preload([:floor, :user])
  end

  @doc """
  Gets a single unit.

  Raises `Ecto.NoResultsError` if the Unit does not exist.

  ## Examples

      iex> get_unit!(123)
      %Unit{}

      iex> get_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_unit!(id), do: Repo.get!(Unit, id) |> Repo.preload([:floor, :user])

  @doc """
  Creates a unit.

  ## Examples

      iex> create_unit(%{field: value})
      {:ok, %Unit{}}

      iex> create_unit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_unit(attrs \\ %{}) do
    %Unit{}
    |> Unit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a unit.

  ## Examples

      iex> update_unit(unit, %{field: new_value})
      {:ok, %Unit{}}

      iex> update_unit(unit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_unit(%Unit{} = unit, attrs) do
    unit
    |> Unit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a unit.

  ## Examples

      iex> delete_unit(unit)
      {:ok, %Unit{}}

      iex> delete_unit(unit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_unit(%Unit{} = unit) do
    Repo.delete(unit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking unit changes.

  ## Examples

      iex> change_unit(unit)
      %Ecto.Changeset{data: %Unit{}}

  """
  def change_unit(%Unit{} = unit, attrs \\ %{}) do
    Unit.changeset(unit, attrs)
  end

#   def get_assignment_data(apartment_id) do
#   Au4.Context.Apartment
#   |> Repo.get!(apartment_id)
#   |> Repo.preload(floors: :units)
# end

# def assign_member_with_scope(user_id, apartment_id, role_name, unit_id \\ nil) do
#   # Using with allows for cleaner error handling if the role doesn't exist
#   with %Au4.Access.Role{} = role <- Repo.get_by(Au4.Access.Role, name: role_name) do
#     attrs = %{
#       user_id: user_id,
#       apartment_id: apartment_id,
#       role_id: role.id,
#       unit_id: unit_id
#     }

#     %UserApartment{}
#     |> UserApartment.changeset(attrs)
#     |> Repo.insert()
#   else
#     nil -> {:error, :role_not_found}
#   end
# end

# def update_user_apartment(%UserApartment{} = user_apartment, attrs) do
#   user_apartment
#   |> UserApartment.changeset(attrs)
#   |> Repo.update()
# end







@doc """
Updates a user_apartment membership (the lease/role).
"""
def update_user_apartment(%UserApartment{} = user_apartment, attrs) do
  user_apartment
  |> UserApartment.changeset(attrs)
  |> Repo.update()
end

# def assign_member_with_scope(user_id, apartment_id, role_name, unit_id \\ nil) do
#   # 1. Get the Role ID based on the name
#   role = Repo.get_by!(Au4.Access.Role, name: role_name)

#   # 2. Prepare the attributes
#   attrs = %{
#     user_id: user_id,
#     apartment_id: apartment_id,
#     role_id: role.id,
#     unit_id: unit_id
#   }

#   # 3. Create the UserApartment record
#   %Au4.Context.UserApartment{}
#   |> Au4.Context.UserApartment.changeset(attrs)
#   |> Repo.insert()
# end

def assign_member_with_scope(user_id, apartment_id, role_name, floor_id \\ nil, unit_id \\ nil) do
  role = Repo.get_by!(Au4.Access.Role, name: role_name)

  attrs = %{
    user_id: user_id,
    apartment_id: apartment_id,
    role_id: role.id,
    floor_id: floor_id, # Added this
    unit_id: unit_id
  }

  %Au4.Context.UserApartment{}
  |> Au4.Context.UserApartment.changeset(attrs)
  |> Repo.insert()
end

def get_assignment_data(apartment_id) do
  Au4.Context.Apartment
  |> Repo.get!(apartment_id)
  |> Repo.preload(floors: :units)
end


def list_all_memberships do
  UserApartment
  |> Repo.all()
  |> Repo.preload([:user, :apartment, :role, :unit])
end

def create_user_apartment(attrs \\ %{}) do
  %UserApartment{}
  |> UserApartment.changeset(attrs)
  |> Repo.insert()
end

# def has_available_units?(apartment) do
#   Enum.any?(apartment.floors, fn floor ->
#     Enum.any?(floor.units, fn unit -> is_nil(unit.user) or Enum.empty?(unit.user) end)
#   end)
# end

def has_available_units?(apartment) do
  Enum.any?(apartment.floors, fn floor ->
    Enum.any?(floor.units, fn unit ->
      # Check for both nil and empty list
      case unit.user do
        nil -> true
        [] -> true
        %{} = user when is_map(user) -> false
        _ -> false
      end
    end)
  end)
end

end
