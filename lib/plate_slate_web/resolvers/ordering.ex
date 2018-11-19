defmodule PlateSlateWeb.Resolvers.Ordering do
  alias PlateSlate.{Ordering, Helpers.Utils}

  def place_order(_, %{input: place_order_input}, _) do
    case Ordering.create_order(place_order_input) do
      {:ok, order} ->
        # The publish is used to send the event to subscriptions
        Absinthe.Subscription.publish(PlateSlateWeb.Endpoint, order, new_order: "*")
        {:ok, %{order: order}}

      {:error, changeset} ->
        {:ok, %{errors: Utils.translate_changeset_errors(changeset)}}
    end
  end
end
