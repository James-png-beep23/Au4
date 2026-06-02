defmodule Au4Web.RequestLive.Index do
  use Au4Web, :live_view
  alias Au4.Embed.Request # Ensure this matches your schema location
  alias Au4.Context

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    # 1. Find the unit assigned to this tenant
    # This logic assumes a tenant has at least one unit assigned via the floors -> units relationship
    assigned_unit = find_user_unit(current_user)

    # 2. Initialize the Request struct and form
    request = %Request{}
    changeset = Request.changeset(request, %{})

    {:ok,
     socket
     |> assign(page_title: "Submit Maintenance Request")
     |> assign(unit: assigned_unit)
     |> assign(request: request)
     |> assign_form(changeset)}
  end

  defp find_user_unit(user) do
  Context.list_apartments_with_floors_and_units()
    |> Enum.flat_map(& &1.floors)
    |> Enum.flat_map(& &1.units)
    # Ensure we preload requests here or in the context function
    |> Enum.find(fn unit ->
        Enum.any?(unit.user, fn u -> u.id == user.id end)
      end)
end

  def handle_event("validate", %{"request" => params}, socket) do
    changeset =
      socket.assigns.request
      |> Request.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"request" => params}, socket) do
    unit = Context.get_unit!(socket.assigns.unit.id)
    # unit = socket.assigns.unit
    current_user = socket.assigns.current_user

      available_date =
          case params["available_date"] do
            "" -> nil
            date_str ->
              # Convert "YYYY-MM-DDTHH:MM" to ISO8601
              case DateTime.from_iso8601(date_str <> ":00Z") do
                {:ok, dt, _} -> dt
                _ -> nil
              end
          end

        request_attrs = %{
          unit_id: unit.id,
          request_type: params["request_type"],
          description: params["description"],
          requested_by: "#{current_user.first_name} #{current_user.last_name}",
          priority: params["priority"],
          status: "Open",
          available_date: available_date
        }

      case Context.create_maintenance_request(unit, request_attrs) do
        {:ok, _updated_unit} ->
          {:noreply,
          socket
          |> put_flash(:info, "Request submitted successfully for #{unit.name}")
          |> push_navigate(to: ~p"/admin/dashboard")}

        {:error, changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
