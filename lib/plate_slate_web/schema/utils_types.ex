defmodule PlateSlateWeb.Schema.UtilsTypes do
  use Absinthe.Schema.Notation

  # Moved here because it is used in many *_types files
  object(:input_error) do
    field(:key, non_null(:string))
    field(:message, non_null(:string))
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

  scalar(:decimal) do
    parse(fn
      %{value: value}, _ ->
        Decimal.parse(value)

      _, _ ->
        :error
    end)

    serialize(&to_string/1)
  end
end
