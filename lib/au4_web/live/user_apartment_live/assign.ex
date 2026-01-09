defmodule Au4Web.UserApartmentLive.Assign do
  use Au4Web, :live_view
  alias Au4.Context
  alias Au4.Access

  @topic "apartment_updates"

  @impl true
  def mount(%{"apartment_id" => apt_id}, _session, socket) do
    apartment = Context.get_assignment_data(apt_id)

    {:ok, assign(socket,
    apartment: apartment,
    roles: Access.list_roles(),
    users: Au4.Account.list_users(),
    selected_user: "",   # Add this
    selected_role: "",
    selected_floor: "",
    selected_unit: ""    # Add this
  )}
    end

@impl true
def handle_event("validate", params, socket) do
  # Extract EVERY value from the params
  user_id = Map.get(params, "user_id", "")
  role_name = Map.get(params, "role_name", "")
  floor_id = Map.get(params, "floor_id", "")
  unit_id = Map.get(params, "unit_id", "") # Match the name in your HTML

  {:noreply,
    socket
    |> assign(:selected_user, user_id)
    |> assign(:selected_role, role_name)
    |> assign(:selected_floor, floor_id)
    |> assign(:selected_unit, unit_id)} # Keep the unit sticky
end

  def handle_event("save", params, socket) do
  # 1. Convert role name back to an ID (or use the name if your context handles it)
  role = Enum.find(socket.assigns.roles, &(&1.name == params["role_name"]))

  assignment_params = %{
    user_id: params["user_id"],
    apartment_id: socket.assigns.apartment.id,
    role_id: role.id,
    floor_id: params["floor_id"],
    unit_id: params["unit_id"]
  }

  case Au4.Context.create_user_apartment(assignment_params) do
    {:ok, _user_apartment} ->
       Phoenix.PubSub.broadcast(Au4.PubSub, @topic, :reloading_apartments)
      {:noreply,
       socket
       |> put_flash(:info, "User assigned successfully!")
       |> push_navigate(to: ~p"/userapartments")} # Go back to the global list

    {:error, _changeset} ->
      {:noreply, put_flash(socket, :error, "Could not save assignment. Check required fields.")}
  end
end
end
