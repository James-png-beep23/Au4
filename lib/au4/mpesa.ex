defmodule Au4.Mpesa do
  @moduledoc """
  The Mpesa context for handling M-Pesa transactions.
  """
  import Ecto.Query
  alias Au4.Mpesa.Transaction
  alias Au4.Repo

  @doc """
  Gets all transactions
  """
  def list_transactions do
    Repo.all(Transaction)
  end

  @doc """
  Gets a transaction by ID
  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Gets a transaction by checkout request ID
  """
  def get_transaction_by_checkout_request_id(checkout_request_id) do
    Repo.get_by(Transaction, checkout_request_id: checkout_request_id)
  end

  @doc """
  Creates a transaction
  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction
  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets all transactions for a user
  """
  def list_user_transactions(user_id) do
    Repo.all(
      from t in Transaction,
        where: t.user_id == ^user_id,
        order_by: [desc: t.inserted_at]
    )
  end

  @doc """
  Gets all transactions for a unit
  """
  def list_unit_transactions(unit_id) do
    Repo.all(
      from t in Transaction,
        where: t.unit_id == ^unit_id,
        order_by: [desc: t.inserted_at]
    )
  end

  @doc """
  Gets pending transactions
  """
  def get_pending_transactions do
    Repo.all(
      from t in Transaction,
        where: t.status == "pending"
    )
  end

  @doc """
  Gets pending transactions older than a certain time
  """
  def get_pending_transactions_older_than(datetime) do
    Repo.all(
      from t in Transaction,
        where: t.status == "pending" and t.inserted_at < ^datetime
    )
  end

  @doc """
  Mark transaction as completed
  """
  def mark_transaction_completed(transaction, receipt_number, result_description \\ "Transaction completed successfully") do
    update_transaction(transaction, %{
      status: "completed",
      mpesa_receipt_number: receipt_number,
      result_description: result_description,
      completed_at: DateTime.utc_now()
    })
  end

  @doc """
  Mark transaction as failed
  """
  def mark_transaction_failed(transaction, result_code, result_description) do
    update_transaction(transaction, %{
      status: "failed",
      result_code: result_code,
      result_description: result_description,
      error_message: result_description,
      completed_at: DateTime.utc_now(),
      retry_count: (transaction.retry_count || 0) + 1
    })
  end

  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end
end
