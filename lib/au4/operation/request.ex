defmodule Au4.Operation.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requests" do
    field :request_type, :string
    field :description, :string
    field :requested_by, :string
    field :priority, :string
    field :assigned_to, :string
    field :due_date, :utc_datetime
    field :available_date, :utc_datetime
    field :status, :string

    belongs_to :unit, Au4.Context.Unit

    timestamps()
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [
      :request_type,
      :description,
      :requested_by,
      :priority,
      :assigned_to,
      :due_date,
      :available_date,
      :status,
      :unit_id
    ])
    |> validate_required([
      :request_type,
      :description,
      :requested_by,
      :priority,
      :status,
      :unit_id
    ])
  end
end
