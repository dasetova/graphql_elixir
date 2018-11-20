defmodule PlateSlateWeb.Schema.Mutation.CreateMenuItemTest do
  use PlateSlateWeb.ConnCase, async: true
  alias PlateSlate.{Repo, Menu}
  import Ecto.Query

  setup do
    PlateSlate.Seeds.run()
    # To mutation createMenuItem
    category_id =
      from(t in Menu.Category, where: t.name == "Sandwiches")
      |> Repo.one!()
      |> Map.fetch!(:id)
      |> to_string()

    user = Factory.create_user("employee")
    conn = build_conn() |> auth_user(user)

    {:ok, category_id: category_id, conn: conn}
  end

  @query """
  mutation($menuItem: MenuItemInput!){
    createMenuItem(input: $menuItem){
      errors { key message }
      menuItem {
        name
        description
        price
      }
    }
  }
  """
  test "createMenuItem field creates an item", %{category_id: category_id, conn: conn} do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }

    response = post(conn, "/api", query: @query, variables: %{"menuItem" => menu_item})

    assert json_response(response, 200) == %{
             "data" => %{
               "createMenuItem" => %{
                 "menuItem" => %{
                   "name" => menu_item["name"],
                   "description" => menu_item["description"],
                   "price" => menu_item["price"]
                 },
                 "errors" => nil
               }
             }
           }
  end

  test "must be authorized as an employee to do menu item creation", %{category_id: category_id} do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }

    user = Factory.create_user("customer")
    conn = build_conn() |> auth_user(user)

    response = post(conn, "/api", query: @query, variables: %{"menuItem" => menu_item})

    assert json_response(response, 200) == %{
             "data" => %{
               "createMenuItem" => nil
             },
             "errors" => [
               %{
                 "locations" => [%{"column" => 0, "line" => 2}],
                 "message" => "unauthorized",
                 "path" => ["createMenuItem"]
               }
             ]
           }
  end

  test "creating a menu item with an existing name fails", %{category_id: category_id, conn: conn} do
    menu_item = %{
      "name" => "Reuben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }

    response = post(conn, "/api", query: @query, variables: %{"menuItem" => menu_item})

    assert json_response(response, 200) == %{
             "data" => %{
               "createMenuItem" => %{
                 "errors" => [
                   %{
                     "key" => "name",
                     "message" => "has already been taken"
                   }
                 ],
                 "menuItem" => nil
               }
             }
           }
  end

  defp auth_user(conn, user) do
    token = PlateSlateWeb.Authentication.sign(%{role: user.role, id: user.id})
    put_req_header(conn, "authorization", "Bearer #{token}")
  end
end
