defmodule Au4.Context.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "units" do
    field :name, :string
    field :description, :string
    field :booking, :string
    field :price, :integer
    field :security, :string
    field :water_unit_price, :string
    field :parking, :string
    field :service_fee, :string
    field :internet, :string
    field :late_penalty, :string
    field :damages, :string
    field :repair, :string
    field :meter_reading, :string
    field :second_readig, :string
    field :key_access_card, :string
    field :utility_reconnection, :string

    belongs_to :floor, Au4.Context.Floor
    many_to_many :user, Au4.Account.User, join_through: Au4.Context.UserApartment, on_replace: :delete
    has_many :user_apartments, Au4.Context.UserApartment
    has_many :requests, Au4.Operation.Request
    has_many :charges, Au4.Operation.Charge

    timestamps(type: :utc_datetime)
  end


  @doc false
  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [
    :name,
    :description,
    :booking,
    :price,
    :security,
    :water_unit_price,
    :parking,
    :service_fee,
    :internet,
    :late_penalty,
    :damages,
    :repair,
    :meter_reading,
    :second_readig,
    :key_access_card,
    :utility_reconnection
  ])
    |> validate_required([:name, :description, :price])


  end
end
