class CreateTeaReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :tea_reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.string :brand
      t.string :name
      t.string :purchase_place
      t.text :description
      t.integer :rating
      t.integer :sweetness
      t.integer :acidity
      t.integer :bitterness
      t.integer :astringency
      t.integer :fruity
      t.integer :spicy
      t.integer :freshness
      t.integer :flowery
      t.text :impression

      t.timestamps
    end
  end
end
