defmodule Au4Web.RoleLive.FormComponent do
  use Au4Web, :live_component

  alias Au4.Access



  @impl true
  def update(%{role: role} = assigns, socket) do
     permissions = Access.list_permissions()
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:permissions, permissions)
     |> assign_new(:form, fn ->
       to_form(Access.change_role(role))
     end)}
  end

  @impl true
def handle_event("validate", %{"role" => role_params}, socket) do
  # Use the original role from the socket, NOT the modified one
  changeset =
    socket.assigns.role
    |> Access.change_role(role_params)
    |> Map.put(:action, :validate)

  {:noreply, assign_form(socket, changeset)}
end

  def handle_event("save", %{"role" => role_params}, socket) do
    save_role(socket, socket.assigns.action, role_params)
  end

 defp save_role(socket, :edit, role_params) do
  case Access.update_role(socket.assigns.role, role_params) do
    {:ok, role} ->
      role_with_permissions = Au4.Repo.preload(role, :permissions)
      notify_parent({:saved, role_with_permissions})

      {:noreply,
       socket
       |> put_flash(:info, "Role updated successfully")
       |> push_patch(to: socket.assigns.patch)}

    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end

  defp save_role(socket, :new, role_params) do
    case Access.create_role(role_params) do
      {:ok, role} ->
        notify_parent({:saved, role})

        {:noreply,
         socket
         |> put_flash(:info, "Role created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})


  # Add this helper function:
  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
