defmodule Au4Web.ChargeLive.Index do
  use Au4Web, :live_view

  alias Au4.Operation
  alias Au4.Context

  @impl true
  def mount(%{"apartment_id" => apartment_id}, _session, socket) do
    current_user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:apartment_id, String.to_integer(apartment_id))
     |> assign(:apartment, nil)
     |> assign(:current_user, current_user)
     |> assign(:water, 0)
     |> assign(:waste, 0)
     |> assign(:other, 0)
     |> assign(:total, 0)
     |> assign(:previous_water_reading, 0)
     |> assign(:current_water_reading, 0)
     |> assign(:water_cost_per_unit, 0)
     |> assign(:water_usage, 0)
     |> assign(:water_charge, 0)
     |> assign(:selected_unit, nil)}
  end

  @impl true
  def handle_params(%{"apartment_id" => apartment_id}, _url, socket) do
    apartment_id = String.to_integer(apartment_id)

    apartment = Context.get_apartment!(apartment_id)
    units = Context.get_unit_in_apartment(apartment_id)

    {:noreply,
     assign(socket,
       apartment: apartment,
       apartment_id: apartment_id,
       units: units
     )}
  end

  @impl true
  def handle_event("calculate_billing_charges", params, socket) do
    previous =
      parse_amount(params["previous_water_reading"])

    current =
      parse_amount(params["current_water_reading"])

    cost_per_unit = Context.get_water_unit_price(params["apartment_id"])

    waste =
      parse_amount(params["waste"])

    other =
      parse_amount(params["other"])

    # Usage × cost per unit
    water_charge = Context.calculate_water_charge(current, previous, cost_per_unit)
    total_charge = Context.charge_total(waste, other, water_charge)
    case Decimal.compare(total_charge, Decimal.new("0")) do
      :gt ->
        Operation.create_charge(params)

      :eq ->
        "insert charges!"

      :lt ->
        "insert charges!"
    end



    {:noreply,
     assign(socket,
       water_charge: water_charge,
       waste: waste,
       other: other,
       total_charge: total_charge
     )}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    charge = Operation.get_charge!(id)

    {:ok, _} = Operation.delete_charge(charge)

    {:noreply, stream_delete(socket, :charges, charge)}
  end

 defp parse_amount(nil), do: Decimal.new("0")
  defp parse_amount(""), do: Decimal.new("0")

  defp parse_amount(value) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, ""} ->
        decimal

      _ ->
        Decimal.new("0")
    end
  end

  defp parse_amount(value) when is_integer(value) do
    Decimal.new(value)
  end

  defp parse_amount(value) when is_float(value) do
    Decimal.from_float(value)
  end
end
