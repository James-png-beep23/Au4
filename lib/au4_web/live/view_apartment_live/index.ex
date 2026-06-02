defmodule Au4Web.ViewApartmentLive.Index do
  use Au4Web, :live_view

  alias Au4.Server

def mount(_params, _session, socket) do
  apartments = Server.get_apartment()

  {:ok,
   socket
   |> assign(:apartments, apartments)
   |> assign(:filtered_apartments, apartments)
   |> assign(:search, "")}
end

  @doc """
  Handles the click event from the apartment card.
  Redirects the user to the specific apartment show page.
  """
  def handle_event("view_apartment", %{"id" => id}, socket) do
    # push_navigate provides a smooth SPA-like transition
    {:noreply, push_navigate(socket, to: ~p"/view/#{id}")}
  end

  def handle_event("search", %{"search" => term}, socket) do
  apartments = socket.assigns.apartments

  filtered =
    Enum.filter(apartments, fn apartment ->
      String.contains?(
        String.downcase(apartment.name <> " " <> apartment.location),
        String.downcase(term)
      )
    end)

  {:noreply,
   socket
   |> assign(:filtered_apartments, filtered)
   |> assign(:search, term)}
end


end
