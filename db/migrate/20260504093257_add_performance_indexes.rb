class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :recipes, [ :is_public, :created_at ]
    add_index :flavor_tags_recipes, :flavor_tag_id
    add_index :flavor_tags_recipes, :recipe_id
    add_index :functional_tags_recipes, :functional_tag_id
    add_index :functional_tags_recipes, :recipe_id
  end
end
