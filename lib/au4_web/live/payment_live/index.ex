

defmodule Au4Web.BillingLive do
  use Au4Web, :live_view

  alias Au4.Context
  alias Au4.StkPush
  alias Au4.Account
  alias Au4.Mpesa

  def mount(%{"apartment_id" => apartment_id}, _session, socket) do

    current_user = socket.assigns.current_user

    {:ok,
     assign(socket,
       apartment: nil,
       apartment_id: nil,
       current_user: current_user,
       price: 0,
       phone: 0
     )}
  end

  def handle_params(%{"apartment_id" => apartment_id}, _url, socket) do
    apartment_id = String.to_integer(apartment_id)

    apartment = Context.get_apartment!(apartment_id)

    price =
      Context.get_rent_per_unit(
        apartment_id,
        socket.assigns.current_user.id
      )

    {:noreply,
     assign(socket,
       apartment: apartment,
       apartment_id: apartment_id,
       price: price || 0
     )}
  end

  # own pay

  def handle_event("pay_rent", _params, socket) do
    user_id = socket.assigns.current_user.id
    apartment_id = socket.assigns.apartment_id
    phone = socket.assigns.current_user.phone_number

    unit_id =
      Context.get_unit_id_by_apartment_and_user(
        apartment_id,
        user_id
      )

    price =
      Context.get_rent_per_unit(
        apartment_id,
        user_id
      )

    cond do
      is_nil(unit_id) ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "You are not assigned to a unit in this apartment."
         )}

      is_nil(price) ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Unable to determine your rent amount."
         )}

      price <= 0 ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Invalid rent amount."
         )}

      is_nil(phone) ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Your account does not have a phone number."
         )}

      true ->
        phone = format_phone(phone)

        send_stk_push(
          socket,
          phone,
          price,
          unit_id,
          "Please check your phone for the M-Pesa payment prompt."
        )
    end
  end

  # prompt

  def handle_event("prompt_tenant",%{"user_id" => user_id},socket) do

    caretaker_id = socket.assigns.current_user.id
    apartment_id = socket.assigns.apartment_id


    user_id = String.to_integer(user_id)


    IO.inspect(caretaker_id, label: "CARETAKER")
    IO.inspect(user_id, label: "TENANT")
    IO.inspect(apartment_id, label: "APARTMENT")

    tenant = Account.get_user!(user_id)

    unit_id =
      Context.get_unit_id_by_apartment_and_user(
        apartment_id,
        user_id
      )

    price =
      Context.get_rent_per_unit(
        apartment_id,
        user_id
      )

    phone = tenant.phone_number

    IO.inspect(unit_id, label: "UNIT")
    IO.inspect(phone, label: "TENANT PHONE")
    IO.inspect(price, label: "RENT")

    cond do
      is_nil(unit_id) ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "This tenant is not assigned to a unit in this apartment."
         )}

      is_nil(price) or price <= 0 ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Invalid rent amount."
         )}

      is_nil(phone) ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Tenant does not have a phone number."
         )}

      true ->

        phone = format_phone(phone)
        send_stk_push(
          socket,
          phone,
          price,
          unit_id,
          "M-Pesa prompt sent to #{tenant.first_name}."
        )
    end
  end



 def handle_event("prompt_foreign_tenant", %{"phone" => phone}, socket) do
  apartment_id = socket.assigns.apartment_id
  user_id = socket.assigns.current_user.id

  unit_id =
    Context.get_unit_id_by_apartment_and_user(
      apartment_id,
      user_id
    )

  price =
    Context.get_rent_per_unit(
      apartment_id,
      user_id
    )

  cond do
    is_nil(unit_id) ->
      {:noreply,
       put_flash(
         socket,
         :error,
         "You are not assigned to a unit in this apartment."
       )}

    is_nil(price) or price <= 0 ->
      {:noreply,
       put_flash(
         socket,
         :error,
         "Invalid rent amount."
       )}

    is_nil(phone) or phone == "" ->
      {:noreply,
       put_flash(
         socket,
         :error,
         "Please enter the payer's phone number."
       )}

    true ->
      phone = format_phone(phone)


      send_stk_push(
        socket,
        phone,
        price,
        unit_id,
        "M-Pesa prompt sent to #{phone}."
      )
  end
end

  defp send_stk_push(socket, phone, price, unit_id, success_message) do
    case StkPush.send_request(phone, price, unit_id) do

      {:ok, %HTTPoison.Response{
        status_code: 200,
        body: body
      }} ->

        response = Jason.decode!(body)

        IO.inspect(response, label: "STK RESPONSE")

        case Mpesa.create_transaction(%{
               checkout_request_id: response["CheckoutRequestID"],
               merchant_request_id: response["MerchantRequestID"],
               amount: price,
               phone_number: phone,
               unit_id: unit_id,
               status: "pending"
             }) do

          {:ok, _transaction} ->
            {:noreply,
             put_flash(
               socket,
               :info,
               success_message
             )}

          {:error, changeset} ->
            IO.inspect(changeset, label: "TRANSACTION ERROR")

            {:noreply,
             put_flash(
               socket,
               :error,
               "STK prompt was sent, but transaction could not be recorded."
             )}
        end

      {:ok, %HTTPoison.Response{
        status_code: status_code,
        body: body
      }} ->

        IO.inspect(body, label: "MPESA ERROR")

        {:noreply,
         put_flash(
           socket,
           :error,
           "M-Pesa request failed (#{status_code})."
         )}

      {:error, %HTTPoison.Error{reason: reason}} ->

        IO.inspect(reason, label: "HTTP ERROR")

        {:noreply,
         put_flash(
           socket,
           :error,
           "Unable to send M-Pesa prompt."
         )}
    end
  end


  # Helper function to format phone numbers
  defp format_phone(phone) when is_binary(phone) do
    cleaned = String.replace(phone, ~r/[^0-9]/, "")

    cond do
      String.starts_with?(cleaned, "254") ->
        cleaned

      String.starts_with?(cleaned, "0") ->
        "254" <> String.slice(cleaned, 1..-1//-1)

      String.starts_with?(cleaned, "254") and String.length(cleaned) == 12 ->
        cleaned

      String.length(cleaned) == 10 and String.starts_with?(cleaned, "7") ->
        "254" <> cleaned

      true ->
        "254" <> cleaned
    end
  end

  defp format_phone(nil), do: nil
end





# defmodule Au4Web.BillingLive do
#   use Au4Web, :live_view

#   alias Au4.Context
#   alias Au4.StkPush

#   def mount(%{"apartment_id" => apartment_id}, _session, socket) do
#     curent_user = socket.assigns.current_user
#     {:ok,
#      assign(socket,
#        apartment: nil,
#        apartment_id: nil,
#        current_user: curent_user,
#        price: 0
#      )}
#   end

#   def handle_params(%{"apartment_id" => apartment_id}, _url, socket) do
#     apartment_id = String.to_integer(apartment_id)
#     apartment = Context.get_apartment!(apartment_id)
#     price = Context.get_rent_per_unit(apartment_id, socket.assigns.current_user.id)

#     {:noreply,
#      assign(socket,
#        apartment: apartment,
#        apartment_id: apartment_id,
#        price: price || 0
#      )}
#   end

#   def handle_event("pay_rent", _params, socket) do
#   user_id = socket.assigns.current_user.id
#   apartment_id = socket.assigns.apartment_id
#   phone = socket.assigns.current_user.phone_number

#   unit_id =
#     Context.get_unit_id_by_apartment_and_user(
#       apartment_id,
#       user_id
#     )

#   price =
#     Context.get_rent_per_unit(
#       apartment_id,
#       user_id
#     )

#   cond do
#     is_nil(unit_id) ->
#       {:noreply,
#        put_flash(
#          socket,
#          :error,
#          "You are not assigned to a unit in this apartment."
#        )}

#     is_nil(price) ->
#       {:noreply,
#        put_flash(
#          socket,
#          :error,
#          "Unable to determine your rent amount."
#        )}

#     price <= 0 ->
#     {:noreply,
#      put_flash(socket, :error,
#        "Invalid rent amount."
#      )}

#     true ->
#       case StkPush.send_request(phone, price, unit_id) do
#         {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
#           response = Jason.decode!(body)

#           {:ok, _transaction} =
#             MpesaTransaction.create_transaction(%{
#               checkout_request_id: response["CheckoutRequestID"],
#               merchant_request_id: response["MerchantRequestID"],
#               amount: price,
#               phone_number: phone,
#               unit_id: unit_id,
#               status: "pending"
#             })

#           IO.puts("STK Push request successful!")
#           IO.inspect(body)

#           {:noreply,
#            put_flash(
#              socket,
#              :info,
#              "Please check your phone for the M-Pesa payment prompt."
#            )}

#         {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
#           IO.puts(
#             "STK Push request failed with status code #{status_code}"
#           )

#           IO.inspect(body)

#           {:noreply,
#            put_flash(
#              socket,
#              :error,
#              "M-Pesa payment request failed."
#            )}

#         {:error, %HTTPoison.Error{reason: reason}} ->
#           IO.puts(
#             "STK Push request failed with error: #{reason}"
#           )

#           {:noreply,
#            put_flash(
#              socket,
#              :error,
#              "Unable to initiate M-Pesa payment."
#            )}
#       end
#   end
# end

# def handle_event("prompt_tenant", %{"user_id" => user_id},socket ) do

#   caretaker_id = socket.assigns.current_user.id
#   apartment_id = socket.assigns.apartment_id

#   user_id = String.to_integer(user_id)

#   tenant = Context.get_user!(user_id)

#   unit_id =
#     Context.get_unit_id_by_apartment_and_user(
#       apartment_id,
#       user_id
#     )

#   price =
#     Context.get_rent_per_unit(
#       apartment_id,
#       user_id
#     )

#   phone = tenant.phone_number

#   IO.inspect(caretaker_id, label: "CARETAKER")
#   IO.inspect(user_id, label: "TENANT")
#   IO.inspect(unit_id, label: "UNIT")
#   IO.inspect(phone, label: "TENANT PHONE")
#   IO.inspect(price, label: "RENT")

#   cond do
#     is_nil(unit_id) ->
#       {:noreply,
#        put_flash(
#          socket,
#          :error,
#          "This tenant is not assigned to a unit."
#        )}

#     is_nil(price) or price <= 0 ->
#       {:noreply,
#        put_flash(
#          socket,
#          :error,
#          "Invalid rent amount."
#        )}

#     is_nil(phone) ->
#       {:noreply,
#        put_flash(
#          socket,
#          :error,
#          "Tenant does not have a phone number."
#        )}

#     true ->
#       case StkPush.send_request(phone, price, unit_id) do

#         {:ok, %HTTPoison.Response{
#           status_code: 200,
#           body: body
#         }} ->

#           response = Jason.decode!(body)

#           {:ok, _transaction} =
#             MpesaTransaction.create_transaction(%{
#               checkout_request_id: response["CheckoutRequestID"],
#               merchant_request_id: response["MerchantRequestID"],
#               amount: price,
#               phone_number: phone,
#               unit_id: unit_id,
#               status: "pending"
#             })

#           IO.inspect(response, label: "STK RESPONSE")

#           {:noreply,
#            put_flash(
#              socket,
#              :info,
#              "M-Pesa prompt sent to #{tenant.first_name}."
#            )}

#         {:ok, %HTTPoison.Response{
#           status_code: status_code,
#           body: body
#         }} ->

#           IO.inspect(body, label: "MPESA ERROR")

#           {:noreply,
#            put_flash(
#              socket,
#              :error,
#              "M-Pesa request failed (#{status_code})."
#            )}

#         {:error, %HTTPoison.Error{reason: reason}} ->

#           IO.inspect(reason, label: "HTTP ERROR")

#           {:noreply,
#            put_flash(
#              socket,
#              :error,
#              "Unable to send M-Pesa prompt."
#            )}
#       end
#   end
# end
# end
