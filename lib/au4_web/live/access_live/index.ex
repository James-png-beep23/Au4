defmodule Au4Web.AccessLive.Index do
  use Au4Web, :live_view
  # alias Au4.Account
  alias Au4.Access

  @impl true
  def mount(_params, _session, socket) do
    roles = Access.list_roles()
    {:ok, assign(socket, users: Access.list_users_with_roles(), roles: roles)}
  end

  @impl true
  def handle_event("toggle_role", %{"user_id" => user_id, "role_id" => role_id}, socket) do
    user = Enum.find(socket.assigns.users, fn u -> u.id == String.to_integer(user_id) end)
    role_id = String.to_integer(role_id)


    current_role_ids = Enum.map(user.roles, & &1.id)

    new_role_ids = if role_id in current_role_ids do
      List.delete(current_role_ids, role_id)
    else
      [role_id | current_role_ids]
    end

    case Access.update_user_roles(user, new_role_ids) do
      {:ok, _updated_user} ->
        {:noreply, assign(socket, users: Access.list_users_with_roles())}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update roles")}
    end
  end
end
