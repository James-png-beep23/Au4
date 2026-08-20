defmodule Au4.Auth do
  @base_url Application.fetch_env!(:au4, :mpesa)[:base_url]
  # @base_url Application.compile_env(:au4, :mpesa)[:base_url]



  def get_token do

      client_id = Application.get_env(:au4, :mpesa)[:consumer_key]
      client_secret = Application.get_env(:au4, :mpesa)[:consumer_secret]

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
