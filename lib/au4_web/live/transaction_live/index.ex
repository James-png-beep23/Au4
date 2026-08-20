defmodule Au4Web.TransactionLive.Index do
  use Au4Web, :live_view

  alias Au4.Mpesa

  @impl true
  def mount(_params, _session, socket) do
    transactions = Mpesa.list_transactions()

    {:ok,
     socket
     |> assign(:page_title, "M-Pesa Transactions")
     |> stream(:transactions, transactions)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Mpesa.get_transaction!(id)
    {:ok, _} = Mpesa.delete_transaction(transaction)

    {:noreply, stream_delete(socket, :transactions, transaction)}
  end
end
