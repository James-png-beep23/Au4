defmodule Au4.Access.RoleUser do
  use Ecto.Schema

  @primary_key false
  schema "role_user" do
    belongs_to :role, Au4.Access.Role
    belongs_to :user, Au4.Account.User
    timestamps(type: :utc_datetime)
  end
end
