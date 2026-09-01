defmodule Au4.Auth do

  def get_token do
    config = Application.fetch_env!(:au4, :mpesa)

    base_url = config[:base_url]
    client_id = config[:consumer_key]
    client_secret = config[:consumer_secret]

    auth = Base.encode64("#{client_id}:#{client_secret}")

    headers = [
      {"Authorization", "Basic #{auth}"}
    ]

    url =
      "#{base_url}/oauth/v1/generate?grant_type=client_credentials"

    case HTTPoison.get(url, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        token = Jason.decode!(body)["access_token"]
        {:ok, token}

      {:ok, %{status_code: status_code, body: body}} ->
        {:error, {status_code, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
