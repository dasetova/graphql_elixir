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

  query do
    import_fields(:menu_queries)
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
