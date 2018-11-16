defmodule PlateSlate.Utils do
  def translate_chageset_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&format_error/1)
    |> IO.inspect(label: "Error converted")
    |> Enum.map(fn
      {key, value} ->
        %{key: key, message: value}
    end)
  end

  @spec format_error(Ecto.Changeset.error()) :: String.t()
  defp format_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      IO.inspect(acc, label: "Accumalator")
      IO.inspect(key, label: "Key")
      IO.inspect(value, label: "Value")
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
