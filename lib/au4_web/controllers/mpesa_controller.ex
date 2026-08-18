defmodule Au4Web.MpesaController do
  use Au4Web, :controller

  def callback(conn, params) do
    IO.puts("===== M-PESA CALLBACK =====")
    IO.inspect(params, label: "CALLBACK PARAMS")

    conn
    |> put_status(:ok)
    |> json(%{
      ResultCode: 0,
      ResultDesc: "Accepted"
    })
  end
end
