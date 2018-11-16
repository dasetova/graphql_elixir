defmodule PlateSlate.Repo.Migrations.AddIndexForMenuItemsNames do
  use Ecto.Migration

  def change do
    create(unique_index(:items, [:name]))
  end
end
