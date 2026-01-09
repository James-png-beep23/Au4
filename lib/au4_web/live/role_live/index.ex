defmodule Au4Web.RoleLive.Index do
  use Au4Web, :live_view

  alias Au4.Access
  alias Au4.Access.Role

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :roles, Access.list_roles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

 defp apply_action(socket, :edit, %{"id" => id}) do
    role =
      id
      |> Access.get_role!()
      |> Au4.Repo.preload(:permissions)

    socket
    |> assign(:page_title, "Edit Role")
    |> assign(:role, role)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Role")
    |> assign(:role, %Role{permissions: []})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Roles")
    |> assign(:role, nil)
  end

  @impl true
  def handle_info({Au4Web.RoleLive.FormComponent, {:saved, role}}, socket) do
    {:noreply, stream_insert(socket, :roles, role)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    role = Access.get_role!(id)
    {:ok, _} = Access.delete_role(role)

    {:noreply, stream_delete(socket, :roles, role)}
  end
end
