class CreateJoinTableFunctionalTagsRecipes < ActiveRecord::Migration[7.2]
  def change
    create_join_table :functional_tags, :recipes do |t|
      # t.index [:functional_tag_id, :recipe_id]
      # t.index [:recipe_id, :functional_tag_id]
    end
  end
end
