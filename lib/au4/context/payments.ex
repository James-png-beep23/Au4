defmodule Au4.Context.Payments do
  use Ecto.Schema
  import Ecto.Changeset

  schema "charges" do
    belongs_to :unit, Au4.Context.Unit
    belongs_to :user, Au4.Account.User

    field :amount, :decimal
    field :status, :string, default: "pending"
    field :due_date, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(charge, attrs) do
    charge
    |> cast(attrs, [:unit_id, :user_id, :amount, :status, :due_date])
    |> validate_required([:unit_id, :user_id, :amount, :due_date])
  end
end
