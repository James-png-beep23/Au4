defmodule Au4.Auth do
  @base_url "https://sandbox.safaricom.co.ke"

  def get_token do
    client_id = "8YllKPd343AdB5hhGP9EQzzcVG2eOhh5etnpQjaW0OPFUmAl"
    client_secret = "Ng4hgG3jbLlMIMUYWcWsIfDmOyieHhPcwRhgJFfpWGRQQ854VZhabDA5J0RxBJEK"

    # Encode credentials for Basic Auth
    auth = Base.encode64("#{client_id}:#{client_secret}")

    #It creates a Basic Auth header. This tells the Safaricom server,
    # "Here are my encoded credentials; please verify them."
    headers = [{"Authorization", "Basic #{auth}"}]

    #API Call: The function makes a GET request to the Safaricom OAuth endpoint to request an access token.

    url = "#{@base_url}/oauth/v1/generate?grant_type=client_credentials"


     # It uses the HTTPoison library to make a GET request to the specific Safaricom endpoint
    case HTTPoison.get(url, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        token = Jason.decode!(body)["access_token"]
        {:ok, token}
      {:error, reason} -> {:error, reason}
    end
  end


end
