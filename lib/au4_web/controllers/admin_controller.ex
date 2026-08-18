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
    {apartments, users, selected_apartment_id, units, tenants, occupied, landlord, rent} = cond do
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

      units = if selected_apartment_id do
          Context.get_unit_in_apartment(selected_apartment_id)
        else
          Context.list_unite()
        end

      occupy = units |> Au4.Repo.preload(user_apartments: [:role])

      occupied = if occupy do
          Enum.filter(occupy, fn occupy ->
          Enum.any?(occupy.user_apartments, fn ua ->
            ua.role.name == "Tenant"
          end)
        end)
      else
        []
      end

      tenants = if selected_apartment_id do
          Account.has_role_tenant(selected_apartment_id)
        else
          Account.list_tenants()
        end

      landlords = users |> Au4.Repo.preload(user_apartments: [:apartment, :role])
      landlord = if landlords do
          Enum.filter(landlords, fn user ->
            Enum.any?(user.user_apartments, fn ua ->
              ua.role.name == "Landlord"
            end)
          end)
        else
          []
        end


        rent =
          if selected_apartment_id do
            Context.get_total_rent_for_apartment(selected_apartment_id)
          else

            Context.get_total_rent_for_all_apartments()
          end





      {Context.list_apartments(), users, selected_apartment_id, units, tenants, occupied, landlord, rent}

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

        rent = Context.get_total_rent_for_apartment(selected_apartment_id)

        units = if selected_apartment_id do
          Context.get_unit_in_apartment(selected_apartment_id)
        else
          Context.list_unite()
        end

      occupy = units |> Au4.Repo.preload(user_apartments: [:role])

      occupied = if occupy do
          Enum.filter(occupy, fn occupy ->
          Enum.any?(occupy.user_apartments, fn ua ->
            ua.role.name == "Tenant"
          end)
        end)
      else
        []
      end

      tenants = if selected_apartment_id do
          Account.has_role_tenant(selected_apartment_id)
        else
          Account.list_tenants()
        end

       assigned_users = Account.list_users_in_apartments([selected_apartment_id])

       landlords = assigned_users |> Au4.Repo.preload(user_apartments: [:apartment, :role])
       landlord = if landlords do
          Enum.filter(landlords, fn user ->
            Enum.any?(user.user_apartments, fn ua ->
              ua.role.name == "Landlord"
            end)
          end)
        else
          []
        end

       {
          assigned_apartments,
          assigned_users,
          selected_apartment_id,
          units,
          tenants,
          occupied,
          landlord,
          rent
        }
    end


     {selected_apartment_id, apartment_list, unit_rent, request, admin, apartment_name, tenant} =
     if !Account.User.has_role?(current_user, "Super admin") do

        selected_apartment_id =
        case params["active_apartment"] do
          nil -> nil
          "" -> nil
          id -> String.to_integer(id)
        end


        apartment_list =
          current_user.user_apartments
          |> Enum.map(& &1.apartment.name)
          |> Enum.uniq()
          |> Enum.join(", ")

       apartment_name =
         current_user.user_apartments
          |> Enum.find_value(fn ua ->
            if ua.apartment_id == selected_apartment_id do
              ua.apartment.name

            end

          #  if ua.role.name == "Tenant" do
          #     ua.apartment.name
          #   end
          end)


         tenant = if selected_apartment_id do
          Account.has_role_tenant(selected_apartment_id)
          else
            []
          end

       unit_rent =
              if selected_apartment_id do
                Context.get_rent_per_unit(
                  selected_apartment_id,
                  current_user.id
                )
              else
                0
              end

        apartment_ids =
          current_user.user_apartments
          |> Enum.map(& &1.apartment_id)
          |> Enum.uniq()


        request = Context.get_unit_requests_in_apartment(apartment_ids, current_user.id)

        admin = Context.get_user_for_admin_view(current_user.id)

        {selected_apartment_id, apartment_list, unit_rent, request, admin, apartment_name, tenant}

       else
        # For super admin, set defaults
        {selected_apartment_id,"",[], [], nil, "", []}
      end


    # 4. Build the stats map (Make sure these keys match your template!)
    stats = %{
      total_users: length(users),
      total_tenants: length(tenants),
      total_apartments: length(apartments),
      total_units: length(units),
      occupied_units: length(occupied),
      vacant_units: length(units) - length(occupied),
      total_landlords: length(landlord),
      monthly_rent_collected: rent || 0,
      unit_rent: unit_rent || 0,

      current_user: current_user,
      primary_apartment_name: apartment_list,
      apartment_owned: apartment_name,
      total_requests: request,
      total_tenant: length(tenant),
      admin: admin,
      user_full_name: "#{current_user.first_name} #{current_user.last_name}"
    }

    render(conn, :index, stats: stats, users: users, apartments: apartments, selected_apartment_id: selected_apartment_id)
  end

  def showpay(conn, %{"id" => id}) do
    user = Account.get_user!(id)

    render(conn, :showpay, user: user)
  end
end
