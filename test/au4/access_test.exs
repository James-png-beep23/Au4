defmodule Au4.AccessTest do
  use Au4.DataCase

  alias Au4.Access

  describe "roles" do
    alias Au4.Access.Role

    import Au4.AccessFixtures

    @invalid_attrs %{name: nil}

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Access.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Access.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Role{} = role} = Access.create_role(valid_attrs)
      assert role.name == "some name"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Access.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Role{} = role} = Access.update_role(role, update_attrs)
      assert role.name == "some updated name"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Access.update_role(role, @invalid_attrs)
      assert role == Access.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Access.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Access.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Access.change_role(role)
    end
  end
end
