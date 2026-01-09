defmodule Au4Web.AdminController do
  use Au4Web, :controller
  alias Au4.Account
  alias Au4.Context
  # alias Au4.Account.User

  plug :put_layout, html: {Au4Web.Layouts, :admin}


def index(conn, _params) do
  current_user = conn.assigns.current_user
                 |> Au4.Repo.preload([:roles, user_apartments: [:role, :apartment]])

  {apartments, users} = if Account.User.has_role?(current_user, "Super admin") do
    {Context.list_apartments(), Account.list_users()}
  else
    assigned_apartments = Enum.map(current_user.user_apartments, & &1.apartment)
    apartment_ids = Enum.map(assigned_apartments, & &1.id)
    assigned_users = Account.list_users_in_apartments(apartment_ids)

    {assigned_apartments, assigned_users}
  end


 apartment_list =
  current_user.user_apartments
  |> Enum.map(fn ua -> ua.apartment.name end)
  |> Enum.join(", ")

  stats = %{
    total_users: length(users),

    total_apartments: length(apartments),
    current_user: current_user,
    primary_apartment_name: apartment_list # Pass the string, not the struct!
  }



  render(conn, :index, stats: stats, users: users, apartments: apartments)
end


end
