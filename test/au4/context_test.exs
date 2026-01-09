defmodule Au4.ContextTest do
  use Au4.DataCase

  alias Au4.Context

  describe "apartments" do
    alias Au4.Context.Apartment

    import Au4.ContextFixtures

    @invalid_attrs %{name: nil, location: nil}

    test "list_apartments/0 returns all apartments" do
      apartment = apartment_fixture()
      assert Context.list_apartments() == [apartment]
    end

    test "get_apartment!/1 returns the apartment with given id" do
      apartment = apartment_fixture()
      assert Context.get_apartment!(apartment.id) == apartment
    end

    test "create_apartment/1 with valid data creates a apartment" do
      valid_attrs = %{name: "some name", location: "some location"}

      assert {:ok, %Apartment{} = apartment} = Context.create_apartment(valid_attrs)
      assert apartment.name == "some name"
      assert apartment.location == "some location"
    end

    test "create_apartment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Context.create_apartment(@invalid_attrs)
    end

    test "update_apartment/2 with valid data updates the apartment" do
      apartment = apartment_fixture()
      update_attrs = %{name: "some updated name", location: "some updated location"}

      assert {:ok, %Apartment{} = apartment} = Context.update_apartment(apartment, update_attrs)
      assert apartment.name == "some updated name"
      assert apartment.location == "some updated location"
    end

    test "update_apartment/2 with invalid data returns error changeset" do
      apartment = apartment_fixture()
      assert {:error, %Ecto.Changeset{}} = Context.update_apartment(apartment, @invalid_attrs)
      assert apartment == Context.get_apartment!(apartment.id)
    end

    test "delete_apartment/1 deletes the apartment" do
      apartment = apartment_fixture()
      assert {:ok, %Apartment{}} = Context.delete_apartment(apartment)
      assert_raise Ecto.NoResultsError, fn -> Context.get_apartment!(apartment.id) end
    end

    test "change_apartment/1 returns a apartment changeset" do
      apartment = apartment_fixture()
      assert %Ecto.Changeset{} = Context.change_apartment(apartment)
    end
  end

  describe "floors" do
    alias Au4.Context.Floor

    import Au4.ContextFixtures

    @invalid_attrs %{name: nil}

    test "list_floors/0 returns all floors" do
      floor = floor_fixture()
      assert Context.list_floors() == [floor]
    end

    test "get_floor!/1 returns the floor with given id" do
      floor = floor_fixture()
      assert Context.get_floor!(floor.id) == floor
    end

    test "create_floor/1 with valid data creates a floor" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Floor{} = floor} = Context.create_floor(valid_attrs)
      assert floor.name == "some name"
    end

    test "create_floor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Context.create_floor(@invalid_attrs)
    end

    test "update_floor/2 with valid data updates the floor" do
      floor = floor_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Floor{} = floor} = Context.update_floor(floor, update_attrs)
      assert floor.name == "some updated name"
    end

    test "update_floor/2 with invalid data returns error changeset" do
      floor = floor_fixture()
      assert {:error, %Ecto.Changeset{}} = Context.update_floor(floor, @invalid_attrs)
      assert floor == Context.get_floor!(floor.id)
    end

    test "delete_floor/1 deletes the floor" do
      floor = floor_fixture()
      assert {:ok, %Floor{}} = Context.delete_floor(floor)
      assert_raise Ecto.NoResultsError, fn -> Context.get_floor!(floor.id) end
    end

    test "change_floor/1 returns a floor changeset" do
      floor = floor_fixture()
      assert %Ecto.Changeset{} = Context.change_floor(floor)
    end
  end

  describe "units" do
    alias Au4.Context.Unit

    import Au4.ContextFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_units/0 returns all units" do
      unit = unit_fixture()
      assert Context.list_units() == [unit]
    end

    test "get_unit!/1 returns the unit with given id" do
      unit = unit_fixture()
      assert Context.get_unit!(unit.id) == unit
    end

    test "create_unit/1 with valid data creates a unit" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Unit{} = unit} = Context.create_unit(valid_attrs)
      assert unit.name == "some name"
      assert unit.description == "some description"
    end

    test "create_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Context.create_unit(@invalid_attrs)
    end

    test "update_unit/2 with valid data updates the unit" do
      unit = unit_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Unit{} = unit} = Context.update_unit(unit, update_attrs)
      assert unit.name == "some updated name"
      assert unit.description == "some updated description"
    end

    test "update_unit/2 with invalid data returns error changeset" do
      unit = unit_fixture()
      assert {:error, %Ecto.Changeset{}} = Context.update_unit(unit, @invalid_attrs)
      assert unit == Context.get_unit!(unit.id)
    end

    test "delete_unit/1 deletes the unit" do
      unit = unit_fixture()
      assert {:ok, %Unit{}} = Context.delete_unit(unit)
      assert_raise Ecto.NoResultsError, fn -> Context.get_unit!(unit.id) end
    end

    test "change_unit/1 returns a unit changeset" do
      unit = unit_fixture()
      assert %Ecto.Changeset{} = Context.change_unit(unit)
    end
  end
end
