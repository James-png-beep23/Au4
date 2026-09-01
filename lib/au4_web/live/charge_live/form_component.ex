defmodule Au4Web.ChargeLive.FormComponent do
  use Au4Web, :live_component

  alias Au4.Operation

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage charge records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="charge-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:water_meter_reading]} type="number" label="meter reading" />
        <.input field={@form[:waste_collction_charges]} type="number" label="waste" />
        <.input field={@form[:other_charges]} type="number" label="other" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Charge</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{charge: charge} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Operation.change_charge(charge))
     end)}
  end

  @impl true
  def handle_event("validate", %{"charge" => charge_params}, socket) do
    changeset = Operation.change_charge(socket.assigns.charge, charge_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"charge" => charge_params}, socket) do
    save_charge(socket, socket.assigns.action, charge_params)
  end

  defp save_charge(socket, :edit, charge_params) do
    case Operation.update_charge(socket.assigns.charge, charge_params) do
      {:ok, charge} ->
        notify_parent({:saved, charge})

        {:noreply,
         socket
         |> put_flash(:info, "Charge updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_charge(socket, :new, charge_params) do
    case Operation.create_charge(charge_params) do
      {:ok, charge} ->
        notify_parent({:saved, charge})

        {:noreply,
         socket
         |> put_flash(:info, "Charge created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
