defmodule Au4Web.ApartmentLive.FormComponent do
  use Au4Web, :live_component

  alias Au4.Context
  alias Au4.Context.{Apartment, Floor, Unit}
  @topic "apartment_updates"


  @impl true
  @spec update(%{:apartment => any(), optional(any()) => any()}, any()) :: {:ok, map()}
  def update(%{apartment: apartment} = assigns, socket) do
    # When creating new, ensure we have at least one floor/unit structure
    apartment = if apartment.id, do: apartment, else: %Apartment{floors: [%Floor{units: [%Unit{}]}]}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:apartment, apartment)
     |> assign_new(:form, fn -> to_form(Context.change_apartment(apartment)) end)}
  end

  @impl true
  def handle_event("validate", %{"apartment" => params}, socket) do
    changeset = Context.change_apartment(socket.assigns.apartment, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

   def handle_event("add-floor", params, socket) do

  current_params = params["apartment"] || socket.assigns.form.params


  temp_id = System.unique_integer([:positive]) |> to_string()
  new_floor = %{"number" => "", "units" => %{"0" => %{"name" => ""}}}


  floors = Map.get(current_params, "floors", %{})
  updated_params = Map.put(current_params, "floors", Map.put(floors, temp_id, new_floor))

  changeset = Context.change_apartment(socket.assigns.apartment, updated_params)
  {:noreply, assign(socket, form: to_form(changeset))}
end

def handle_event("add-unit", %{"floor-index" => f_idx} = params, socket) do

  current_params = params["apartment"] || socket.assigns.form.params

  temp_id = System.unique_integer([:positive]) |> to_string()
  new_room = %{"name" => "", "description" => ""}


  updated_params = update_in(current_params, ["floors", f_idx, "units"], fn units ->
    Map.put(units || %{}, temp_id, new_room)
  end)

  changeset = Context.change_apartment(socket.assigns.apartment, updated_params)
  {:noreply, assign(socket, form: to_form(changeset))}
end

  def handle_event("remove-floor", %{"index" => index}, socket) do
    params = socket.assigns.form.params
    updated_params = Map.put(params, "floors", Map.delete(params["floors"], index))

    changeset = Context.change_apartment(socket.assigns.apartment, updated_params)
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("remove-unit", %{"floor-index" => f_idx, "unit-index" => r_idx}, socket) do
    params = socket.assigns.form.params
    updated_params = update_in(params, ["floors", f_idx, "units"], &Map.delete(&1, r_idx))

    changeset = Context.change_apartment(socket.assigns.apartment, updated_params)
    {:noreply, assign(socket, form: to_form(changeset))}
  end



  def handle_event("save", %{"apartment" => apartment_params}, socket) do
    save_apartment(socket, socket.assigns.action, apartment_params)
  end

  defp save_apartment(socket, :edit, params) do
    case Context.update_apartment(socket.assigns.apartment, params) do
      {:ok, apartment} ->
        send(self(), {:saved, apartment})
        Phoenix.PubSub.broadcast(Au4.PubSub, @topic, :reloading_apartments)
        {:noreply, socket |> put_flash(:info, "Updated!") |> push_patch(to: socket.assigns.patch)}
      {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_apartment(socket, :new, params) do
    case Context.create_apartment(params) do
      {:ok, apartment} ->
        send(self(), {:saved, apartment})
         Phoenix.PubSub.broadcast(Au4.PubSub, @topic, :reloading_apartments)
        {:noreply, socket |> put_flash(:info, "Created!") |> push_patch(to: socket.assigns.patch)}
      {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
