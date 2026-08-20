defmodule Au4.Mpesa.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mpesa_transactions" do
    field :status, :string, default: "pending"
    field :amount, :integer
    field :phone_number, :string
    field :unit_id, :integer
    field :user_id, :integer
    field :apartment_id, :integer
    field :checkout_request_id, :string
    field :merchant_request_id, :string
    field :mpesa_receipt_number, :string
    field :result_code, :integer
    field :result_description, :string
    field :transaction_date, :utc_datetime
    field :payment_for_month, :integer
    field :payment_for_year, :integer
    field :error_message, :string
    field :retry_count, :integer, default: 0
    field :callback_received_at, :utc_datetime
    field :expires_at, :utc_datetime
    field :initiated_by, :string
    field :initiated_from_ip, :string
    field :metadata, :map, default: %{}

    timestamps()
  end

  @doc """
  Changeset for creating a new transaction
  """
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :status,
      :amount,
      :phone_number,
      :unit_id,
      :user_id,
      :apartment_id,
      :checkout_request_id,
      :merchant_request_id,
      :metadata,
      :retry_count,
      :initiated_by,
      :initiated_from_ip,
      :expires_at,
      :payment_for_month,
      :payment_for_year
    ])
    |> validate_required([:status, :amount, :phone_number, :unit_id])
    |> validate_number(:amount, greater_than: 0)
    |> validate_length(:phone_number, min: 10, max: 15)
    |> unique_constraint(:checkout_request_id)
  end

  @doc """
  Changeset for updating a transaction
  """
  def update_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :status,
      :mpesa_receipt_number,
      :result_code,
      :result_description,
      :transaction_date,
      :error_message,
      :retry_count,
      :callback_received_at,
      :metadata
    ])
    |> validate_inclusion(:status, ["pending", "completed", "failed", "cancelled"])
  end
end
