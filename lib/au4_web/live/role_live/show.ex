defmodule Au4Web.RoleLive.Show do
  use Au4Web, :live_view

  alias Au4.Access

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:role, Access.get_role!(id))}
  end

  defp page_title(:show), do: "Show Role"
  defp page_title(:edit), do: "Edit Role"
end
