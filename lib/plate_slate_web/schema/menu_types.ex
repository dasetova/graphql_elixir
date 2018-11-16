defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation
  alias PlateSlateWeb.Resolvers

  # ------Bussiness Types---------
  object :menu_item do
    interfaces([:search_result])
    field(:id, :id)
    field(:name, :string)
    field(:description, :string)
    field(:price, :decimal)
    field(:added_on, :date)
  end

  object :category do
    interfaces([:search_result])
    field(:id, :id)
    field(:name, :string)

    field(:items, list_of(:menu_item)) do
      # Better with preload?
      resolve(&Resolvers.Menu.items_for_category/3)
    end
  end

  # --------------Menu Queries definitions-----------
  object :menu_queries do
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

    field(:categories, list_of(:category)) do
      arg(:filter, :categories_filters)
      arg(:order, type: :sort_order)
      resolve(&Resolvers.Menu.categories/3)
    end

    field(:search, list_of(:search_result)) do
      arg(:matching, non_null(:string))
      resolve(&Resolvers.Menu.search/3)
    end
  end

  # --------------Menu Mutations definitions-------------
  object(:menu_mutations) do
    field(:create_menu_item, :menu_item) do
      # The input name is because is the same name use in Relay (Framework)
      # Could be any name
      arg(:input, non_null(:menu_item_input))
      resolve(&Resolvers.Menu.create_item/3)
    end
  end

  # ---------------Input Types (Helpers)----------------

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

  @desc "Required fields to register a menu_item"
  input_object(:menu_item_input) do
    field(:name, non_null(:string))
    field(:description, non_null(:string))
    field(:price, non_null(:decimal))
    field(:category_id, non_null(:id))
  end

  # ---------------Unions and Interfaces----------------
  interface(:search_result) do
    field(:name, :string)

    resolve_type(fn
      %PlateSlate.Menu.Item{}, _ ->
        :menu_item

      %PlateSlate.Menu.Category{}, _ ->
        :category

      _, _ ->
        nil
    end)
  end

  union(:search_result_union) do
    types([:menu_item, :category])

    resolve_type(fn
      %PlateSlate.Menu.Item{}, _ ->
        :menu_item

      %PlateSlate.Menu.Category{}, _ ->
        :category

      _, _ ->
        nil
    end)
  end
end
