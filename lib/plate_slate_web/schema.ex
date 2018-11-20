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
  alias PlateSlateWeb.Schema.Middleware

  # Import types defined in PlateSlateWeb.Schema.MenuTypes
  import_types(__MODULE__.MenuTypes)
  import_types(__MODULE__.OrderingTypes)
  import_types(__MODULE__.UtilsTypes)
  import_types(__MODULE__.AccountsTypes)

  # Defining middleware to a field
  def middleware(middleware, field, %{identifier: :allergy_info} = object) do
    # The allergy_info is a list of maps field, when is getted from the database
    # this comes in a map of strings.
    # This function change the default resolution to that field changet the
    # MapGet default (with the atom), converting atom to string
    new_middleware = {Absinthe.Middleware.MapGet, to_string(field.identifier)}

    middleware
    |> Absinthe.Schema.replace_default(new_middleware, field, object)
  end

  # Defines the middleware to execute when the queries are mutations.
  # Adding the ChangesetErrors translator
  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Middleware.ChangesetErrors]
  end

  # When no mutation, then the middleware will be the same
  def middleware(middleware, _field, _object) do
    middleware
  end

  query do
    # Imports the object in MenuTypes. There are the queries defined to menu context
    import_fields(:menu_queries)
  end

  mutation do
    import_fields(:menu_mutations)
    import_fields(:ordering_mutations)
    import_fields(:accounts_mutations)
  end

  subscription do
    import_fields(:ordering_subscriptions)
  end
end
