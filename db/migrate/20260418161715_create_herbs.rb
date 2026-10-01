class CreateHerbs < ActiveRecord::Migration[7.2]
  def change
    create_table :herbs do |t|
      t.string :name,        null: false  # ← null: false を追加（必須項目）
      t.text   :description
      t.string :image        # ← Active Storageを使うので後で不要になる
      t.text   :caution

      t.timestamps
    end
  end
end
