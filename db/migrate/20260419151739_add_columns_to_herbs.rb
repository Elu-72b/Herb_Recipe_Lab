class AddColumnsToHerbs < ActiveRecord::Migration[7.2]
  def change
    add_column :herbs, :alias_name,           :string  # 別名
    add_column :herbs, :active_ingredients,   :text    # 有効成分
    add_column :herbs, :flavor_description,   :text    # 風味の特徴
    add_column :herbs, :effect_description,   :text    # 効能の説明
    add_column :herbs, :caution_description,  :text    # 禁忌の説明
    add_column :herbs, :history,              :text    # 歴史
  end
end
