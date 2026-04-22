class CreateRecipeHerbs < ActiveRecord::Migration[7.2]
  def change
    create_table :recipe_herbs do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :herb, null: false, foreign_key: true
      t.float :quantity
      t.integer :unit

      t.timestamps
    end
  end
end
