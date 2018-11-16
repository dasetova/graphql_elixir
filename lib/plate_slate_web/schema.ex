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

  # Import types defined in PlateSlateWeb.Schema.MenuTypes
  import_types(__MODULE__.MenuTypes)
  import_types(__MODULE__.UtilsTypes)

  query do
    # Imports the object in MenuTypes. There are the queries defined to menu context
    import_fields(:menu_queries)
  end

  mutation do
    import_fields(:menu_mutations)
  end
end
