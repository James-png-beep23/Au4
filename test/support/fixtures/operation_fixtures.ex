defmodule Au4.OperationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Au4.Operation` context.
  """

  @doc """
  Generate a charge.
  """
  def charge_fixture(attrs \\ %{}) do
    {:ok, charge} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Au4.Operation.create_charge()

    charge
  end
end
