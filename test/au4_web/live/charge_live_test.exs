defmodule Au4Web.ChargeLiveTest do
  use Au4Web.ConnCase

  import Phoenix.LiveViewTest
  import Au4.OperationFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_charge(_) do
    charge = charge_fixture()
    %{charge: charge}
  end

  describe "Index" do
    setup [:create_charge]

    test "lists all charges", %{conn: conn, charge: charge} do
      {:ok, _index_live, html} = live(conn, ~p"/charges")

      assert html =~ "Listing Charges"
      assert html =~ charge.name
    end

    test "saves new charge", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/charges")

      assert index_live |> element("a", "New Charge") |> render_click() =~
               "New Charge"

      assert_patch(index_live, ~p"/charges/new")

      assert index_live
             |> form("#charge-form", charge: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#charge-form", charge: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/charges")

      html = render(index_live)
      assert html =~ "Charge created successfully"
      assert html =~ "some name"
    end

    test "updates charge in listing", %{conn: conn, charge: charge} do
      {:ok, index_live, _html} = live(conn, ~p"/charges")

      assert index_live |> element("#charges-#{charge.id} a", "Edit") |> render_click() =~
               "Edit Charge"

      assert_patch(index_live, ~p"/charges/#{charge}/edit")

      assert index_live
             |> form("#charge-form", charge: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#charge-form", charge: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/charges")

      html = render(index_live)
      assert html =~ "Charge updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes charge in listing", %{conn: conn, charge: charge} do
      {:ok, index_live, _html} = live(conn, ~p"/charges")

      assert index_live |> element("#charges-#{charge.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#charges-#{charge.id}")
    end
  end

  describe "Show" do
    setup [:create_charge]

    test "displays charge", %{conn: conn, charge: charge} do
      {:ok, _show_live, html} = live(conn, ~p"/charges/#{charge}")

      assert html =~ "Show Charge"
      assert html =~ charge.name
    end

    test "updates charge within modal", %{conn: conn, charge: charge} do
      {:ok, show_live, _html} = live(conn, ~p"/charges/#{charge}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Charge"

      assert_patch(show_live, ~p"/charges/#{charge}/show/edit")

      assert show_live
             |> form("#charge-form", charge: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#charge-form", charge: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/charges/#{charge}")

      html = render(show_live)
      assert html =~ "Charge updated successfully"
      assert html =~ "some updated name"
    end
  end
end
