# ---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
# ---
defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.{Menu, Helpers.Utils}

  def menu_items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def categories(_, args, _) do
    {:ok, Menu.list_categories(args)}
  end

  def items_for_category(category, _, _) do
    query = Ecto.assoc(category, :items)
    {:ok, PlateSlate.Repo.all(query)}
  end

  def search(_, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end

  def create_item(_, %{input: params}, _) do
    case Menu.create_item(params) do
      {:error, changeset} ->
        # Adding more information to the errors in the changeset
        {:ok, %{errors: Utils.translate_chageset_errors(changeset)}}

      {:ok, menu_item} ->
        {:ok, %{menu_item: menu_item}}
    end
  end

  def update_item(_, %{input: %{id: id} = params}, _) do
    case Menu.get_item(id) do
      %Menu.Item{} = item ->
        case Menu.update_item(item, params) do
          {:error, changeset} ->
            # Adding more information to the errors in the changeset
            {:ok, %{errors: Utils.translate_chageset_errors(changeset)}}

          {:ok, menu_item} ->
            {:ok, %{menu_item: menu_item}}
        end

      nil ->
        # Adding more information to the errors in the changeset
        {:ok, %{errors: [key: "id", message: "item doesn't exists"]}}
    end
  end
end
