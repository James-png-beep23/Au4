defmodule Au4Web.MpesaController do
  use Au4Web, :controller
  alias Au4.Mpesa

  def callback(conn, params) do
    IO.inspect(params, label: "🔔 M-PESA CALLBACK RECEIVED")

    # Parse the callback
    body = params["Body"] || %{}
    stk_callback = body["stkCallback"] || %{}
    result_code = stk_callback["ResultCode"] || 1
    checkout_request_id = stk_callback["CheckoutRequestID"]
    result_desc = stk_callback["ResultDesc"] || "Unknown"

    # Log the details
    IO.inspect(%{
      checkout_request_id: checkout_request_id,
      result_code: result_code,
      result_desc: result_desc
    }, label: "Callback Details")

    # Find and update the transaction
    case Mpesa.get_transaction_by_checkout_request_id(checkout_request_id) do
      nil ->
        IO.warn("Transaction not found for checkout_id: #{checkout_request_id}")
        json(conn, %{"ResultCode" => 1, "ResultDesc" => "Transaction not found"})

      transaction ->
        if result_code == 0 do
          # Successful payment
          callback_metadata = stk_callback["CallbackMetadata"] || %{}
          items = callback_metadata["Item"] || []

          receipt = Enum.find_value(items, fn item ->
            if item["Name"] == "MpesaReceiptNumber", do: item["Value"]
          end)

          amount = Enum.find_value(items, fn item ->
            if item["Name"] == "Amount", do: item["Value"]
          end)

          transaction_date = Enum.find_value(items, fn item ->
            if item["Name"] == "TransactionDate", do: item["Value"]
          end)

          update_data = %{
            status: "completed",
            mpesa_receipt_number: receipt,
            amount: amount, 
            result_code: result_code,
            result_description: result_desc,
            transaction_date: parse_transaction_date(transaction_date),
            callback_received_at: DateTime.utc_now()
          }

          case Mpesa.update_transaction(transaction, update_data) do
            {:ok, updated} ->
              IO.inspect(updated, label: "✅ Transaction completed")
              json(conn, %{"ResultCode" => 0, "ResultDesc" => "Success"})
            {:error, changeset} ->
              IO.inspect(changeset, label: "❌ Failed to update")
              json(conn, %{"ResultCode" => 1, "ResultDesc" => "Update failed"})
          end
        else
          # Failed payment
          update_data = %{
            status: "failed",
            result_code: result_code,
            result_description: result_desc,
            error_message: result_desc,
            callback_received_at: DateTime.utc_now()
          }

          case Mpesa.update_transaction(transaction, update_data) do
            {:ok, updated} ->
              IO.inspect(updated, label: "❌ Transaction failed")
              json(conn, %{"ResultCode" => result_code, "ResultDesc" => result_desc})
            {:error, changeset} ->
              IO.inspect(changeset, label: "❌ Failed to update")
              json(conn, %{"ResultCode" => 1, "ResultDesc" => "Update failed"})
          end
        end
    end
  end


    def simulate_callback(conn, %{"checkout_request_id" => checkout_id}) do
      transaction = Mpesa.get_transaction_by_checkout_request_id(checkout_id)

      if transaction do
        # Simulate a successful callback
        Mpesa.update_transaction(transaction, %{
          status: "completed",
          mpesa_receipt_number: "SIM_#{:rand.uniform(999999)}",
          result_code: 0,
          result_description: "Simulated successful payment",
          callback_received_at: DateTime.utc_now()
        })

        json(conn, %{
          "status" => "success",
          "message" => "Transaction marked as completed",
          "transaction_id" => transaction.id
        })
      else
        json(conn, %{"error" => "Transaction not found"})
      end
    end

  defp parse_transaction_date(nil), do: nil
  defp parse_transaction_date(date_string) when is_binary(date_string) do
    # M-Pesa date format: YYYYMMDDHHMMSS
    case DateTime.from_iso8601(
      "#{String.slice(date_string, 0, 4)}-#{String.slice(date_string, 4, 2)}-#{String.slice(date_string, 6, 2)}T#{String.slice(date_string, 8, 2)}:#{String.slice(date_string, 10, 2)}:#{String.slice(date_string, 12, 2)}Z"
    ) do
      {:ok, datetime, _offset} -> datetime
      _ -> nil
    end
  end
  defp parse_transaction_date(_), do: nil
end
