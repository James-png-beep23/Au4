defmodule Au4.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    # Create table with all necessary fields
    create table(:mpesa_transactions) do
      # Core transaction fields
      add :status, :string, null: false, default: "pending"
      add :amount, :integer, null: false
      add :phone_number, :string, null: false

      # Foreign keys
      add :unit_id, references(:units, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :apartment_id, references(:apartments, on_delete: :nothing)

      # M-Pesa request IDs
      add :checkout_request_id, :string, null: false
      add :merchant_request_id, :string

      # M-Pesa callback response fields
      add :mpesa_receipt_number, :string
      add :result_code, :integer
      add :result_description, :string
      add :transaction_date, :string

      # Payment period tracking (useful for rent reconciliation)
      add :payment_for_month, :date
      add :payment_for_year, :integer

      # Error tracking
      add :error_message, :text
      add :retry_count, :integer, default: 0

      # Timing information
      add :callback_received_at, :utc_datetime
      add :expires_at, :utc_datetime

      # Audit trail
      add :initiated_by, references(:users, on_delete: :nothing)
      add :initiated_from_ip, :inet

      # Metadata for future use
      add :metadata, :map, default: %{}

      # Timestamps
      timestamps(default: fragment("NOW()"))
    end

    # Create all indexes for performance
    create index(:mpesa_transactions, [:checkout_request_id], unique: true)
    create index(:mpesa_transactions, [:mpesa_receipt_number], where: "mpesa_receipt_number IS NOT NULL", unique: true)
    create index(:mpesa_transactions, [:unit_id])
    create index(:mpesa_transactions, [:user_id])
    create index(:mpesa_transactions, [:apartment_id])
    create index(:mpesa_transactions, [:status])
    create index(:mpesa_transactions, [:phone_number])
    create index(:mpesa_transactions, [:inserted_at])
    create index(:mpesa_transactions, [:payment_for_month])
    create index(:mpesa_transactions, [:status, :inserted_at])
    create index(:mpesa_transactions, [:unit_id, :status])
  end
end
