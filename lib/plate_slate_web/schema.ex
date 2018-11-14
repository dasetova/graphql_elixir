# ---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
# ---
defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  alias PlateSlateWeb.Resolvers

  query do
    field :menu_items, list_of(:menu_item) do
      # arg(:matching, :string)
      # Changing the way filters are pass
      # Resuming filters in a input_object
      # non_null makes filter mandatory
      arg(:filter, :menu_item_filter)
      # # Defining a type sort_order. Is a enum created by me
      arg(:order, type: :sort_order, default_value: :asc)

      resolve(&Resolvers.Menu.menu_items/3)
    end

    field :categories, list_of(:category) do
      arg(:filter, :categories_filters)
      arg(:order, type: :sort_order)
      resolve(&Resolvers.Menu.categories/3)
    end
  end

  object :menu_item do
    field(:id, :id)
    field(:name, :string)
    field(:description, :string)
    field(:added_on, :date)
  end

  object :category do
    field(:id, :id)
    field(:name, :string)
  end

  @desc "Filtering options for the menu list"
  input_object(:menu_item_filter) do
    # This fields also can have the non_null statement
    @desc "Matching a name"
    field(:name, :string)

    @desc "Matching a category name"
    field(:category, :string)

    @desc "Matching a tag"
    field(:tag, :string)

    @desc "Priced above a value"
    field(:price_above, :float)

    @desc "Priced below a value"
    field(:price_below, :float)

    @desc "Added to the menu before this date"
    field(:added_before, :date)

    @desc "Added to the menu after this date"
    field(:added_after, :date)
  end

  @desc "Filtering options for the categories"
  input_object(:categories_filters) do
    @desc "Matching a name"
    field(:name, :string)
  end

  enum :sort_order do
    value(:asc)
    value(:desc)
  end

  # Type defined than can be use in fields
  # This is an example -> Absinthe.Type.Custom has several types
  scalar :date do
    parse(fn input ->
      # Validating the String type to avoid exceptions parsing to date
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           # Parsing logic: Converts value from user into an Elixir term
           {:ok, date} <- Date.from_iso8601(value) do
        {:ok, date}
      else
        _ -> :error
      end
    end)

    serialize(fn date ->
      # Serialization logic: converts an elixir term back into a value JSON
      Date.to_iso8601(date)
    end)
  end

  scalar :email do
    parse(fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           # Parsing logic: Converts value from user into an Elixir term
           [username, domain] <- value |> String.splitter("@") |> Enum.to_list() do
        {:ok, {username, domain}}
      else
        _ -> :error
      end
    end)

    serialize(fn {username, domain} = _email ->
      username <> "@" <> domain
    end)
  end
end
