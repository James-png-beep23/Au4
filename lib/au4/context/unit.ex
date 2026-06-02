defmodule Au4.Context.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "units" do
    field :name, :string
    field :description, :string
    field :booking, :string
    field :price, :decimal

    belongs_to :floor, Au4.Context.Floor
    many_to_many :user, Au4.Account.User, join_through: Au4.Context.UserApartment, on_replace: :delete
    has_many :user_apartments, Au4.Context.UserApartment
    embeds_many :requests, Au4.Embed.Request, on_replace: :delete

    timestamps(type: :utc_datetime)
  end


  @doc false
  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [:name, :description, :booking, :price])
    |> validate_required([:name, :description, :price])
    |> cast_embed(:requests, with: &Au4.Embed.Request.changeset/2)

  end
end
