defmodule PlateSlateWeb.Schema.OrderingTypes do
  use Absinthe.Schema.Notation
  alias PlateSlateWeb.Resolvers.Ordering
  alias PlateSlateWeb.Schema.Middleware

  object(:ordering_mutations) do
    field(:place_order, :order_result) do
      arg(:input, non_null(:place_order_input))
      middleware(Middleware.Authorize, :any)
      resolve(&Ordering.place_order/3)
    end

    field(:ready_order, :order_result) do
      arg(:id, non_null(:id))
      resolve(&Ordering.ready_order/3)
    end

    field(:complete_order, :order_result) do
      arg(:id, non_null(:id))
      resolve(&Ordering.complete_order/3)
    end
  end

  object(:ordering_subscriptions) do
    field :new_order, :order do
      config(fn _args, %{context: context} ->
        case context[:current_user] do
          %{role: "customer", id: id} ->
            {:ok, topic: id}

          %{role: "employee"} ->
            {:ok, topic: "*"}

          _ ->
            {:error, "unauthorized"}
        end
      end)
    end

    field(:update_order, :order) do
      arg(:id, non_null(:id))
      # In this case, the topic is important to separate the events
      # For every order
      config(fn args, _info -> {:ok, topic: args.id} end)

      # In the trigger macro:
      # 1st arg: List of mutations whose trigger the subscription
      # 2th arg: fn to resolve the topic
      trigger(
        [:ready_order, :complete_order],
        topic: fn
          %{order: order} -> [order.id]
          _ -> []
        end
      )

      # This resolve function is used to transform the response from the mutation
      # Resolve function
      resolve(fn %{order: order}, _, _ ->
        {:ok, order}
      end)
    end
  end

  input_object(:order_item_input) do
    field(:menu_item_id, non_null(:id))
    field(:quantity, non_null(:integer))
  end

  input_object(:place_order_input) do
    field(:customer_number, :integer)
    # items must be in the mutation request
    # items list can't be null
    field(:items, non_null(list_of(non_null(:order_item_input))))
  end

  object(:order_result) do
    field(:order, :order)
    field(:errors, list_of(:input_error))
  end

  object(:order) do
    field(:id, :id)
    field(:customer_number, :integer)
    field(:items, list_of(:order_item))
    field(:state, :integer)
  end

  object(:order_item) do
    field(:name, :string)
    field(:quantity, :integer)
  end
end
