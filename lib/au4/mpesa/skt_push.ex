defmodule Au4.StkPush do

  def send_request(phone, amount, unit_id) do
    {:ok, token} = Au4.Auth.get_token()

    config = Application.fetch_env!(:au4, :mpesa)

    base_url = config[:base_url]
    short_code = config[:shortcode]
    passkey = config[:passkey]
    callback_url = config[:callback_url]

    timestamp =
      DateTime.utc_now()
      |> DateTime.add(3, :hour)
      |> Calendar.strftime("%Y%m%d%H%M%S")

    password =
      Base.encode64("#{short_code}#{passkey}#{timestamp}")

    body =
      Jason.encode!(%{
        "BusinessShortCode" => short_code,
        "Password" => password,
        "Timestamp" => timestamp,
        "TransactionType" => "CustomerPayBillOnline",
        "Amount" => round(amount),
        "PartyA" => phone,
        "PartyB" => short_code,
        "PhoneNumber" => phone,
        "CallBackURL" => callback_url,
        "AccountReference" => "UNIT_#{unit_id}",
        "TransactionDesc" => "Payment for goods"
      })

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

    HTTPoison.post(
      "#{base_url}/mpesa/stkpush/v1/processrequest",
      body,
      headers
    )
  end


  def query_status(checkout_request_id) do
    {:ok, token} = Au4.Auth.get_token()

    config = Application.fetch_env!(:au4, :mpesa)

    base_url = config[:base_url]
    short_code = config[:shortcode]
    passkey = config[:passkey]

    timestamp =
      DateTime.utc_now()
      |> DateTime.add(3, :hour)
      |> Calendar.strftime("%Y%m%d%H%M%S")

    password =
      Base.encode64("#{short_code}#{passkey}#{timestamp}")

    body =
      Jason.encode!(%{
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

    url =
      "#{base_url}/mpesa/stkpushquery/v1/query"

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
