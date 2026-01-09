defmodule Au4.Context.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "units" do
    field :name, :string
    field :description, :string
    field :booking, :string

    belongs_to :floor, Au4.Context.Floor
    many_to_many :user, Au4.Account.User, join_through: Au4.Context.UserApartment, on_replace: :delete
    has_many :user_apartments, Au4.Context.UserApartment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [:name, :description, :booking])
    |> validate_required([:name, :description])

  end
end
