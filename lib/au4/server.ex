defmodule Au4.Server do
  use GenServer
  alias Au4.Context

  @topic "apartment_updates"
  @booking_topic "bookings"

  # --- Client API ---

  def start_link(opt \\ []) do
    GenServer.start_link(__MODULE__, opt, name: __MODULE__)
  end

  def get_apartment do
    GenServer.call(__MODULE__, :get_apartment)
  end

  @doc "Adds a temporary booking for a unit"
  def book_unit(unit_id, user_id) do
    GenServer.cast(__MODULE__, {:book_unit, unit_id, user_id})
  end

  @doc "Returns all temporary bookings from memory"
  def get_live_bookings do
    GenServer.call(__MODULE__, :get_live_bookings)
  end

  # --- Server Callbacks ---

  @impl true
  def init(_opts) do
    Phoenix.PubSub.subscribe(Au4.PubSub, @topic)
    # state.apartment holds DB data; state.bookings holds transient memory data
    {:ok, %{apartment: Context.list_apartments(), bookings: %{}}}
  end

  @impl true
  def handle_call(:get_apartment, _from, state) do
    {:reply, state.apartment, state}
  end

  @impl true
  def handle_call(:get_live_bookings, _from, state) do
    {:reply, state.bookings, state}
  end

  @impl true
  def handle_cast({:book_unit, unit_id, user_id}, state) do
    # Map.update adds the user_id to a list for that unit_id
    new_bookings = Map.update(state.bookings, unit_id, [user_id], fn existing ->
      [user_id | existing]
    end)

    # Notify LiveViews that a new booking happened
    Phoenix.PubSub.broadcast(Au4.PubSub, @booking_topic, {:update_bookings, new_bookings})

    {:noreply, %{state | bookings: new_bookings}}
  end

  @impl true
  def handle_info(:reloading_apartments, state) do
    {:noreply, %{state | apartment: Context.list_apartments()}}
  end

end
