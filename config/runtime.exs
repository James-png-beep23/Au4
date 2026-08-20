import Config

if System.get_env("PHX_SERVER") do
  config :au4, Au4Web.Endpoint, server: true
end

# run this on powershell to set the environment variables for M-Pesa configuration:

# $env:MPESA_BASE_URL = "https://sandbox.safaricom.co.ke"
# $env:MPESA_SHORTCODE = "174379"
# $env:MPESA_PASSKEY = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
# $env:MPESA_CONSUMER_KEY = "8YllKPd343AdB5hhGP9EQzzcVG2eOhh5etnpQjaW0OPFUmAl"
# $env:MPESA_CONSUMER_SECRET = "Ng4hgG3jbLlMIMUYWcWsIfDmOyieHhPcwRhgJFfpWGRQQ854VZhabDA5J0RxBJEK"
# $env:MPESA_CALLBACK_URL = "https://nonrhythmical-clementina-unspottable.ngrok-free.dev/api/mpesa/callback"

# M-Pesa runtime configuration
# config :au4, :mpesa,
#   base_url: System.get_env("MPESA_BASE_URL") || "https://sandbox.safaricom.co.ke",
#   shortcode: System.get_env("MPESA_SHORTCODE"),
#   passkey: System.get_env("MPESA_PASSKEY"),
#   consumer_key: System.get_env("MPESA_CONSUMER_KEY"),
#   consumer_secret: System.get_env("MPESA_CONSUMER_SECRET"),
#   callback_url: System.get_env("MPESA_CALLBACK_URL")

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 =
    if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :au4, Au4.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :au4, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :au4, Au4Web.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

    # config/runtime.exs
import Config

# M-Pesa Configuration
  config :au4, :mpesa,
    base_url: System.get_env("MPESA_BASE_URL", "https://api.safaricom.co.ke"),
    consumer_key: System.get_env("MPESA_CONSUMER_KEY"),
    consumer_secret: System.get_env("MPESA_CONSUMER_SECRET"),
    passkey: System.get_env("MPESA_PASSKEY"),
    shortcode: System.get_env("MPESA_SHORTCODE"),
    callback_url: System.get_env("MPESA_CALLBACK_URL"),
    environment: :production
else
  config :au4, :mpesa,
    base_url: "https://sandbox.safaricom.co.ke",
    consumer_key: "8YllKPd343AdB5hhGP9EQzzcVG2eOhh5etnpQjaW0OPFUmAl",
    consumer_secret: "Ng4hgG3jbLlMIMUYWcWsIfDmOyieHhPcwRhgJFfpWGRQQ854VZhabDA5J0RxBJEK",
    passkey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919",
    shortcode: "174379",
    callback_url: "https://nonrhythmical-clementina-unspottable.ngrok-free.dev/api/mpesa/callback",
    environment: :sandbox
end
