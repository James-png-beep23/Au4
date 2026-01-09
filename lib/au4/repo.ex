defmodule Au4.Repo do
  use Ecto.Repo,
    otp_app: :au4,
    adapter: Ecto.Adapters.Postgres
end
