defmodule Au4.ContextFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Au4.Context` context.
  """

  @doc """
  Generate a apartment.
  """
  def apartment_fixture(attrs \\ %{}) do
    {:ok, apartment} =
      attrs
      |> Enum.into(%{
        location: "some location",
        name: "some name"
      })
      |> Au4.Context.create_apartment()

    apartment
  end

  @doc """
  Generate a floor.
  """
  def floor_fixture(attrs \\ %{}) do
    {:ok, floor} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Au4.Context.create_floor()

    floor
  end

  @doc """
  Generate a unit.
  """
  def unit_fixture(attrs \\ %{}) do
    {:ok, unit} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Au4.Context.create_unit()

    unit
  end
end
