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

  def ready_order(_, %{id: id}, _) do
    order = Ordering.get_order!(id)

    with({:ok, order} <- Ordering.update_order(order, %{state: "ready"})) do
      {:ok, %{order: order}}
    else
      {:error, changeset} ->
        {:ok, %{errors: Utils.translate_changeset_errors(changeset)}}
    end
  end

  def complete_order(_, %{id: id}, _) do
    order = Ordering.get_order!(id)

    with({:ok, order} <- Ordering.update_order(order, %{state: "complete"})) do
      {:ok, %{order: order}}
    else
      {:error, changeset} ->
        {:ok, %{errors: Utils.translate_changeset_errors(changeset)}}
    end
  end
end
