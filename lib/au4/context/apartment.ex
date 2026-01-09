defmodule Au4.Context.Apartment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "apartments" do
    field :name, :string
    field :location, :string

    many_to_many :users, Au4.Account.User, join_through: Au4.Context.UserApartment, on_replace: :delete
    has_many :user_apartments, Au4.Context.UserApartment
    has_many :floors, Au4.Context.Floor, on_delete: :delete_all, on_replace: :delete



    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(apartment, attrs) do
    apartment
    |> cast(attrs, [:name, :location])
    |> validate_required([:name, :location])
    |> cast_assoc(:floors, with: &Au4.Context.Floor.changeset/2)

  end
end
