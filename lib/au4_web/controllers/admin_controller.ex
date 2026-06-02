defmodule Au4Web.AdminController do
  use Au4Web, :controller
  alias Au4.Account
  alias Au4.Context

  plug :put_layout, html: {Au4Web.Layouts, :admin}

  def index(conn, params) do
    # 1. Load the user with all necessary associations
    current_user =
      conn.assigns.current_user
      |> Au4.Repo.preload([:roles, user_apartments: [:role, :apartment]])




    #  apartment = Context.list_apartments()


    # 2. Determine which apartments and users to show based on role
    {apartments, users, selected_apartment_id} = cond do
      Account.User.has_role?(current_user, "Super admin") ->

      selected_apartment_id =
        case params["active_apartment"] do
          nil -> nil
          "" -> nil
          id -> String.to_integer(id)
        end

      users =
        if selected_apartment_id do
          Account.list_users_in_apartments([selected_apartment_id])
          |> Au4.Repo.preload(user_apartments: [:apartment, :role])
        else
          Account.list_users()
          |> Au4.Repo.preload(user_apartments: [:apartment, :role])
        end

      {Context.list_apartments(), users, selected_apartment_id}

      # Tenant and Owner logic are effectively the same: see what you are assigned to
      true ->
       assigned_apartments =
        current_user.user_apartments
        |> Enum.map(& &1.apartment)
        |> Enum.uniq_by(& &1.id)

      apartment_ids = Enum.map(assigned_apartments, & &1.id)


       selected_apartment_id =
        case params["active_apartment"] do
          nil -> List.first(apartment_ids)
          "" -> List.first(apartment_ids)
          id -> String.to_integer(id)
        end


      assigned_users = Account.list_users_in_apartments([selected_apartment_id])

        {assigned_apartments, assigned_users, selected_apartment_id}
    end


     {apartment_list, request, admin} =
     if !Account.User.has_role?(current_user, "Super admin") do
        apartment_list =
          current_user.user_apartments
          |> Enum.map(& &1.apartment.name)
          |> Enum.uniq()
          |> Enum.join(", ")

        apartment_ids =
          current_user.user_apartments
          |> Enum.map(& &1.apartment_id)
          |> Enum.uniq()

        request = Context.get_unit_requests_in_apartment(apartment_ids, current_user.id)

        admin = Context.get_user_for_admin_view(current_user.id)

        {apartment_list, request, admin}

       else
        # For super admin, set defaults
        {"", [], nil}
      end

    # 4. Build the stats map (Make sure these keys match your template!)
    stats = %{
      total_users: length(users),
      total_apartments: length(apartments),

      current_user: current_user,
      primary_apartment_name: apartment_list,
      total_requests: request,
      admin: admin,
      user_full_name: "#{current_user.first_name} #{current_user.last_name}"
    }

    render(conn, :index, stats: stats, users: users, apartments: apartments, selected_apartment_id: selected_apartment_id)
  end
end
