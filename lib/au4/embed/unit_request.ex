defmodule Au4.Embed.Request do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :unit_id, :integer
    field :request_type, :string
    field :description, :string
    field :requested_by, :string
    field :priority, :string
    field :status, :string, default: "Open"
    field :assigned_to, :string
    field :available_date, :utc_datetime
    field :due_date, :utc_datetime
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [
      :unit_id,
      :request_type,
      :description,
      :requested_by,
      :priority,
      :status,
      :assigned_to,
      :available_date,
      :due_date
    ])
    |> validate_required([:request_type])
    |> validate_inclusion(:priority, ["Low", "Medium", "High"])
    |> validate_inclusion(:status, ["Open", "In Progress", "Closed"])
    # |> validate_by_request_type()
  end

end
