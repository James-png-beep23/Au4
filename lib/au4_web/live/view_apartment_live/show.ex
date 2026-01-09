defmodule Au4Web.ViewApartmentLive.Show do
  use Au4Web, :live_view

  alias Au4.Context
  alias Au4.Server

  @booking_topic "bookings"
  @topic "apartment_updates"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Au4.PubSub, @booking_topic)
      Phoenix.PubSub.subscribe(Au4.PubSub, @topic)
    end

    socket =
      socket
      |> assign(:current_user, socket.assigns[:current_user])
      |> assign(:live_bookings, Server.get_live_bookings()) # Load initial memory state

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {:noreply, assign(socket, :apartment, Context.get_apartment!(id))}
  end

  @impl true
  def handle_event("book_unit", %{"unit-id" => unit_id}, socket) do
    user_id = socket.assigns.current_user.id
    unit_id_int = String.to_integer(unit_id)

    # Cast to GenServer (Transient memory update)
    Server.book_unit(unit_id_int, user_id)

    {:noreply, put_flash(socket, :info, "Expression of interest sent!")}
  end

  @impl true
  def handle_info({:update_bookings, new_bookings}, socket) do
    # This keeps all connected users' counts in sync
    {:noreply, assign(socket, :live_bookings, new_bookings)}
  end

  @impl true
  def handle_info(:reloading_apartments, socket) do
    # Refresh apartment data from DB when notified
    apartments = Server.get_apartment()
    {:noreply, assign(socket, :apartment, Enum.find(apartments, &(&1.id == socket.assigns.apartment.id)))}
  end
end
