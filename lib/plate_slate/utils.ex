defmodule PlateSlate.Utils do
  def translate_chageset_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, _} -> msg end)
  end
end
