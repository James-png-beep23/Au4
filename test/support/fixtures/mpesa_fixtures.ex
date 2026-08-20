defmodule Au4.MpesaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Au4.Mpesa` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        status: "some status"
      })
      |> Au4.Mpesa.create_transaction()

    transaction
  end
end
