defmodule Au4Web.ApartmentLive.Show do
  use Au4Web, :live_view
  alias Au4.Context
  alias Au4.Context.Unit
  alias Decimal
  alias Au4.Repo
  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    # Initialize bulk billing form
    {:ok,
     socket
     |> assign(:bulk_charges, %{
       security: nil,
       parking: nil,
       water_unit_price: nil,
       service_fee: nil,
       internet: nil,
       late_penalty: nil,
       key_access_card: nil,
       utility_reconnection: nil,
       damages: nil,
       repair: nil
     })
     |> assign(:selected_units, [])
     |> assign(:show_bulk_form, false)
     |> assign(:bulk_loading, false)
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    apartment = Context.get_apartment!(id) |> Repo.preload([floors: [units: [:user]]])

    # Get total unit count for the apartment
    total_units = apartment.floors |> Enum.flat_map(& &1.units) |> length()

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:apartment, apartment)
     |> assign(:total_units, total_units)}
  end

  # Handle toggling the bulk form
  def handle_event("toggle_bulk_form", _params, socket) do
    {:noreply, assign(socket, :show_bulk_form, !socket.assigns.show_bulk_form)}
  end

  # Handle bulk charge updates
  def handle_event("update_bulk_charges", %{"bulk_charges" => charges}, socket) do
    # Convert string values to decimal
    parsed_charges =
      charges
      |> Enum.map(fn {k, v} ->
        {String.to_existing_atom(k), if(v == "", do: nil, else: v)}
      end)
      |> Enum.into(%{})

    {:noreply, assign(socket, :bulk_charges, parsed_charges)}
  end

  @impl true
  def handle_event("apply_bulk_update", %{"action" => action, "bulk_charges" => charges}, socket) do
    charges =
      for {key, value} <- charges, into: %{} do
        {String.to_existing_atom(key), if(value == "", do: nil, else: value)}
      end

    unit_ids =
      case action do
        "all" ->
          socket.assigns.apartment.floors
          |> Enum.flat_map(& &1.units)
          |> Enum.map(& &1.id)

        "selected" ->
          socket.assigns.selected_units
      end

    if unit_ids == [] do
      {:noreply, put_flash(socket, :error, "Please select at least one unit.")}
    else
      {count, _} = update_units(unit_ids, charges)

      updated_apartment =
        Context.get_apartment!(socket.assigns.apartment.id)
        |> Repo.preload([floors: [units: [:user]]])

      message =
        case action do
          "all" -> "Updated #{count} units successfully!"
          "selected" -> "Updated #{count} selected units successfully!"
        end

      {:noreply,
       socket
       |> put_flash(:info, message)
       |> assign(:selected_units, [])
       |> assign(:show_bulk_form, false)
       |> assign(:apartment, updated_apartment)}
    end
  end

  # Handle selecting/deselecting units for bulk update
  def handle_event("toggle_unit_selection", %{"unit_id" => unit_id}, socket) do
    unit_id_int = String.to_integer(unit_id)
    selected = socket.assigns.selected_units

    new_selected =
      if unit_id_int in selected do
        List.delete(selected, unit_id_int)
      else
        [unit_id_int | selected]
      end

    {:noreply, assign(socket, :selected_units, new_selected)}
  end

  defp update_units(unit_ids, charges) do
    update_map =
      charges
      |> Enum.filter(fn {_key, value} -> not is_nil(value) end)

    query = from(u in Unit, where: u.id in ^unit_ids)

    Repo.update_all(query, set: update_map)
  end

  defp page_title(:show), do: "Show Apartment"
  defp page_title(:edit), do: "Edit Apartment"
end
