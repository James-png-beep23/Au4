defmodule Au4.MpesaTest do
  use Au4.DataCase

  alias Au4.Mpesa

  describe "transactions" do
    alias Au4.Mpesa.Transaction

    import Au4.MpesaFixtures

    @invalid_attrs %{status: nil}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Mpesa.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Mpesa.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{status: "some status"}

      assert {:ok, %Transaction{} = transaction} = Mpesa.create_transaction(valid_attrs)
      assert transaction.status == "some status"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mpesa.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      update_attrs = %{status: "some updated status"}

      assert {:ok, %Transaction{} = transaction} = Mpesa.update_transaction(transaction, update_attrs)
      assert transaction.status == "some updated status"
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Mpesa.update_transaction(transaction, @invalid_attrs)
      assert transaction == Mpesa.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Mpesa.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Mpesa.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Mpesa.change_transaction(transaction)
    end
  end
end
