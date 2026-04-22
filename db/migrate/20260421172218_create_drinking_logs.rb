class CreateDrinkingLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :drinking_logs do |t|
      t.references :recipe, null: false, foreign_key: true
      t.integer :rating
      t.integer :sweetness
      t.integer :bitterness
      t.integer :astringency
      t.integer :freshness
      t.integer :savory
      t.integer :spicy
      t.integer :fruity
      t.integer :acidity
      t.text :impression

      t.timestamps
    end
  end
end
