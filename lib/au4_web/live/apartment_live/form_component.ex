
defmodule Au4Web.ApartmentLive.FormComponent do
  use Au4Web, :live_component

  alias Au4.Context
  alias Au4.Context.{Apartment, Floor, Unit}

  @topic "apartment_updates"

  @impl true
  def update(%{apartment: apartment} = assigns, socket) do
    # When creating new, ensure we have at least one floor/unit structure
    apartment =
      if apartment.id do
        apartment
      else
        %Apartment{floors: [%Floor{units: [%Unit{}]}]}
      end

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

def handle_event("add-floor", _params, socket) do
  current_params =
    case socket.assigns.form.params do
      %{} ->
        apartment_to_params(socket.assigns.apartment)

      params ->
        params
    end

  temp_id = System.unique_integer([:positive]) |> to_string()

  new_floor = %{
    "name" => "",
    "units" => %{
      "0" => %{
        "name" => "",
        "description" => "",
        "booking" => "none",
        "price" => ""
      }
    }
  }

  floors = Map.get(current_params, "floors", %{})

  updated_params =
    Map.put(
      current_params,
      "floors",
      Map.put(floors, temp_id, new_floor)
    )

  changeset =
    Context.change_apartment(
      socket.assigns.apartment,
      updated_params
    )

  {:noreply,
   assign(socket, :form, to_form(changeset))}
end

def handle_event("add-unit", %{"floor-index" => f_idx} = _params, socket) do
  current_params = socket.assigns.form.params

  temp_id = System.unique_integer([:positive]) |> to_string()
  new_unit = %{"name" => "", "description" => "", "price" => "", "booking" => "none"}

  updated_params =
    update_in(current_params, ["floors", f_idx, "units"], fn units ->
      Map.put(units || %{}, temp_id, new_unit)
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

        {:noreply,
         socket
         |> put_flash(:info, "Updated!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp apartment_to_params(apartment) do
  %{
    "name" => apartment.name,
    "location" => apartment.location,
    "floors" =>
      apartment.floors
      |> Enum.with_index()
      |> Enum.into(%{}, fn {floor, index} ->
        {
          Integer.to_string(index),
          %{
            "id" => to_string(floor.id),
            "name" => floor.name,
            "units" =>
              floor.units
              |> Enum.with_index()
              |> Enum.into(%{}, fn {unit, unit_index} ->
                {
                  Integer.to_string(unit_index),
                  %{
                    "id" => to_string(unit.id),
                    "name" => unit.name,
                    "description" => unit.description,
                    "booking" => unit.booking,
                    "price" => to_string(unit.price || "")
                  }
                }
              end)
          }
        }
      end)
  }
end

  defp save_apartment(socket, :new, params) do
    case Context.create_apartment(params) do
      {:ok, apartment} ->
        send(self(), {:saved, apartment})
        Phoenix.PubSub.broadcast(Au4.PubSub, @topic, :reloading_apartments)

        {:noreply,
         socket
         |> put_flash(:info, "Created!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
#   def handle_event("add-unit", %{"floor-index" => f_idx}, socket) do
#   current_params =
#     case socket.assigns.form.params do
#       %{} ->
#         apartment_to_params(socket.assigns.apartment)

#       params ->
#         params
#     end

#   temp_id = System.unique_integer([:positive]) |> to_string()

#   new_unit = %{
#     "name" => "",
#     "description" => "",
#     "price" => "",
#     "booking" => "none"
#   }

#   updated_params =
#     update_in(
#       current_params,
#       ["floors", f_idx, "units"],
#       fn units ->
#         Map.put(units || %{}, temp_id, new_unit)
#       end
#     )

#   changeset =
#     Context.change_apartment(
#       socket.assigns.apartment,
#       updated_params
#     )

#   {:noreply, assign(socket, form: to_form(changeset))}
# end
end
