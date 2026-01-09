defmodule Au4Web.UserApartmentLive.Index do
  use Au4Web, :live_view
  alias Au4.Context
  alias Au4.Repo
  alias Au4.Context.UserApartment

  @impl true
  def mount(_params, _session, socket) do
    # Fetching the "bridge" planks directly
    memberships =
      UserApartment
      |> Repo.all()
      |> Repo.preload([:user, :apartment, :role, :unit])

    {:ok, assign(socket, :memberships, memberships)}
  end

  # This allows you to update the role or unit directly from the master list
  @impl true
  def handle_event("update_membership", %{"id" => id, "role_id" => rid}, socket) do
    membership = Repo.get!(UserApartment, id)

    case Context.update_user_apartment(membership, %{role_id: rid}) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "Lease updated") |> refresh_data()}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Update failed")}
    end
  end

  defp refresh_data(socket) do
    memberships = UserApartment |> Repo.all() |> Repo.preload([:user, :apartment, :role, :unit])
    assign(socket, :memberships, memberships)
  end



  defp role_style(nil), do: "bg-gray-100 text-gray-500"
  defp role_style(%{name: "owner"}), do: "bg-amber-100 text-amber-700 border border-amber-200"
  defp role_style(%{name: "tenant"}), do: "bg-green-100 text-green-700 border border-green-200"
  defp role_style(%{name: "caretaker"}), do: "bg-purple-100 text-purple-700 border border-purple-200"
  defp role_style(_), do: "bg-blue-100 text-blue-700"
end
