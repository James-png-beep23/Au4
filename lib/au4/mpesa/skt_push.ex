defmodule Au4.StkPush do
  # alias Au4.Context
  @base_url "https://sandbox.safaricom.co.ke"

  #This is the service that triggers a secure PIN prompt on a user's phone to authorize a payment.

  def send_request(phone, amount, unit_id, number_of_attendees) do
    # calls Au4.Auth.get_token() to get the required Bearer token
    {:ok, token} = Au4.Auth.get_token()

    timestamp =
      DateTime.utc_now()
      |> DateTime.add(3, :hour)
      |> Calendar.strftime("%Y%m%d%H%M%S")
    short_code = "174379"
    passkey = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"


    password = Base.encode64("#{short_code}#{passkey}#{timestamp}")
   # payload construction: The function constructs a JSON payload with all the necessary parameters required
   # by the Safaricom API to process the STK Push request. This includes details like the business shortcode,
   # password, timestamp, transaction type, amount, phone number, callback URL, and more.
    body = Jason.encode!(%{
      "BusinessShortCode" => short_code,
      "Password" => password,
      "Timestamp" => timestamp,
      "TransactionType" => "CustomerPayBillOnline",
      "Amount" => round(amount),
      "PartyA" => phone,
      "PartyB" => short_code,
      "PhoneNumber" => phone,
      # "CallBackURL" => "https://yourdomain.com/api/mpesa/callback",
      "CallBackURL" => "https://nonrhythmical-clementina-unspottable.ngrok-free.dev/api/mpesa/callback",
      "AccountReference" => "Order_123",
      "unit_id" => unit_id,
      "number_of_attendees" => number_of_attendees,
      "TransactionDesc" => "Payment for goods"
    })

    # uses HTTPoison.post to send all this data to Safaricom's processrequest endpoint, along with the appropriate
    # headers for authentication and content type.

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

    HTTPoison.post("#{@base_url}/mpesa/stkpush/v1/processrequest", body, headers)
  end



   def query_status(checkout_request_id) do
    {:ok, token} = Au4.Auth.get_token()

    timestamp =
      DateTime.utc_now()
      |> DateTime.add(3, :hour)
      |> Calendar.strftime("%Y%m%d%H%M%S")

    short_code = "174379"
    passkey = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
    password = Base.encode64("#{short_code}#{passkey}#{timestamp}")

    body = Jason.encode!(%{
      "BusinessShortCode" => short_code,
      "Password" => password,
      "Timestamp" => timestamp,
      "CheckoutRequestID" => checkout_request_id
    })

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

    # Different endpoint for querying status
    url = "https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query"

    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: 200, body: resp_body}} ->
        {:ok, Jason.decode!(resp_body)}
      {:ok, %{body: resp_body}} ->
        {:error, Jason.decode!(resp_body)}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
