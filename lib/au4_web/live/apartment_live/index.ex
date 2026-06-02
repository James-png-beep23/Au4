defmodule Au4Web.ApartmentLive.Index do
  use Au4Web, :live_view

  alias Au4.Context
  alias Au4.Context.Apartment

  @impl true
  def mount(_params, _session, socket) do

     apartments = Context.list_apartments()

    {:ok,
       socket
          |> assign(:all_apartments, apartments)
          |> stream(:apartments, apartments)
          |> assign(:search, "")}

  end

 def handle_event("search", %{"search" => search}, socket) do
      all_apartments = socket.assigns.all_apartments
      term = String.downcase(search || "")

      filtered =
        Enum.filter(all_apartments, fn apartment ->
          name = String.downcase(apartment.name || "")
          location = String.downcase(apartment.location || "")

          String.contains?(name, term) or
          String.contains?(location, term)
        end)

      {:noreply,
      socket
      |> assign(:search, search)
      |> stream(:apartments, filtered, reset: true)} # ✅ IMPORTANT
    end


  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Apartment")
    |> assign(:apartment, Context.get_apartment!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Apartment")
    |> assign(:apartment, %Apartment{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Apartments")
    |> assign(:apartment, nil)
  end

  @impl true
  def handle_info({Au4Web.ApartmentLive.FormComponent, {:saved, apartment}}, socket) do
    {:noreply, stream_insert(socket, :apartments, apartment)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    apartment = Context.get_apartment!(id)
    {:ok, _} = Context.delete_apartment(apartment)

    {:noreply, stream_delete(socket, :apartments, apartment)}
  end
end
