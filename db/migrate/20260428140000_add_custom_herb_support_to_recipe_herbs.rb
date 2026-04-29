class AddCustomHerbSupportToRecipeHerbs < ActiveRecord::Migration[7.2]
  def change
    change_column_null :recipe_herbs, :herb_id, true
    add_column :recipe_herbs, :custom_herb_name, :string
  end
end
