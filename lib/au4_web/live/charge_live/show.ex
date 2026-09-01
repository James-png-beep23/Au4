defmodule Au4Web.ChargeLive.Show do
  use Au4Web, :live_view

  alias Au4.Operation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:charge, Operation.get_charge!(id))}
  end

  defp page_title(:show), do: "Show Charge"
  defp page_title(:edit), do: "Edit Charge"
end
