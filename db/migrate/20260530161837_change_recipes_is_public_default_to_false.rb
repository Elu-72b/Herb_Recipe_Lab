class ChangeRecipesIsPublicDefaultToFalse < ActiveRecord::Migration[7.2]
  def up
    change_column_default :recipes, :is_public, from: true, to: false
    # 既存データはそのまま（全件 true を維持）
  end

  def down
    change_column_default :recipes, :is_public, from: false, to: true
  end
end