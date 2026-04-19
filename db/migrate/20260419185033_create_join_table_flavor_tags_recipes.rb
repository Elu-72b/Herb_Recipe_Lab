class CreateJoinTableFlavorTagsRecipes < ActiveRecord::Migration[7.2]
  def change
    create_join_table :flavor_tags, :recipes do |t|
      # t.index [:flavor_tag_id, :recipe_id]
      # t.index [:recipe_id, :flavor_tag_id]
    end
  end
end
