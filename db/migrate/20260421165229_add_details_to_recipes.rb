class AddDetailsToRecipes < ActiveRecord::Migration[7.2]
  def change
    add_column :recipes, :brewed_at, :date
    add_column :recipes, :amount, :integer
    add_column :recipes, :memo, :text
    add_column :recipes, :is_public, :boolean, default: false, null: false
    remove_column :recipes, :content, :text
  end
end
