defmodule Au4.OperationTest do
  use Au4.DataCase

  alias Au4.Operation

  describe "charges" do
    alias Au4.Operation.Charge

    import Au4.OperationFixtures

    @invalid_attrs %{name: nil}

    test "list_charges/0 returns all charges" do
      charge = charge_fixture()
      assert Operation.list_charges() == [charge]
    end

    test "get_charge!/1 returns the charge with given id" do
      charge = charge_fixture()
      assert Operation.get_charge!(charge.id) == charge
    end

    test "create_charge/1 with valid data creates a charge" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Charge{} = charge} = Operation.create_charge(valid_attrs)
      assert charge.name == "some name"
    end

    test "create_charge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Operation.create_charge(@invalid_attrs)
    end

    test "update_charge/2 with valid data updates the charge" do
      charge = charge_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Charge{} = charge} = Operation.update_charge(charge, update_attrs)
      assert charge.name == "some updated name"
    end

    test "update_charge/2 with invalid data returns error changeset" do
      charge = charge_fixture()
      assert {:error, %Ecto.Changeset{}} = Operation.update_charge(charge, @invalid_attrs)
      assert charge == Operation.get_charge!(charge.id)
    end

    test "delete_charge/1 deletes the charge" do
      charge = charge_fixture()
      assert {:ok, %Charge{}} = Operation.delete_charge(charge)
      assert_raise Ecto.NoResultsError, fn -> Operation.get_charge!(charge.id) end
    end

    test "change_charge/1 returns a charge changeset" do
      charge = charge_fixture()
      assert %Ecto.Changeset{} = Operation.change_charge(charge)
    end
  end
end
