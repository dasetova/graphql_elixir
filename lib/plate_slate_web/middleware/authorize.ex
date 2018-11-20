defmodule PlateSlateWeb.Schema.Middleware.Authorize do
  @moduledoc """
  This plug is used to validate the authentication
  This Middleware is used before call the resolver
  If the error is put in the Absinthe.Resolution struc
  The resolver won't be called
  """
  @behaviour Absinthe.Middleware

  def call(resolution, role) do
    with(
      %{current_user: current_user} <- resolution.context,
      true <- correct_role?(current_user, role)
    ) do
      resolution
    else
      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "unauthorized"})
    end
  end

  # This is for pages where the role is any -> Employee or Customer
  defp correct_role?(%{}, :any), do: true
  # This is for pages where the role must be the specified
  defp correct_role?(%{role: role}, role), do: true
  # This is do return the unauthorized message
  defp correct_role?(_, _), do: false
end
