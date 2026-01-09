defmodule Au4.AccessFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Au4.Access` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Au4.Access.create_role()

    role
  end
end
