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
      |> Repo.preload([:user, :apartment, :floor, :role, :unit])

    {:ok, socket
    |> assign(:memberships, memberships)
    |> assign(:search, "")
    |> assign(:user, memberships)
  }
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

  # def handle_event("search", %{"search" => search}, socket) do
  #   memberships = socket.assigns.user

  #   filtered =
  #     Enum.filter(memberships, fn membership ->
  #       String.contains?(
  #         String.downcase(membership.user.name <> " " <> membership.apartment.name),
  #         String.downcase(search)
  #       )
  #     end)

  #   {:noreply,
  #    socket
  #    |> assign(:memberships, filtered)
  #    |> assign(:search, search)}
  # end

def handle_event("search", %{"search" => search}, socket) do
  all_memberships = socket.assigns.user
  term = String.downcase(search || "")

  filtered =
    Enum.filter(all_memberships, fn membership ->
      user = membership.user
      apartment = membership.apartment
      unit = membership.unit

      full_name =
        ((user.first_name || "") <> " " <> (user.last_name || ""))
        |> String.downcase()

      email = String.downcase(user.email || "")
      apartment_name = String.downcase(apartment.name || "")
      unit_name = String.downcase((unit && unit.name) || "")

      String.contains?(full_name, term) or
      String.contains?(email, term) or
      String.contains?(apartment_name, term) or
      String.contains?(unit_name, term)
    end)

  {:noreply,
   socket
   |> assign(:memberships, filtered)
   |> assign(:search, search)}
end

  def handle_event("delete_membership", %{"id" => id}, socket) do
    membership = Repo.get!(UserApartment, id)

    case Context.delete_user_apartment(membership) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "Lease deleted") |> refresh_data()}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Deletion failed")}
    end
  end

  defp refresh_data(socket) do
    memberships = UserApartment |> Repo.all() |> Repo.preload([:user, :apartment, :floor, :role, :unit])
    assign(socket, :memberships, memberships)
  end





  defp role_style(nil), do: "bg-gray-100 text-gray-500"
  defp role_style(%{name: "owner"}), do: "bg-amber-100 text-amber-700 border border-amber-200"
  defp role_style(%{name: "tenant"}), do: "bg-green-100 text-green-700 border border-green-200"
  defp role_style(%{name: "caretaker"}), do: "bg-purple-100 text-purple-700 border border-purple-200"
  defp role_style(_), do: "bg-blue-100 text-blue-700"
end
