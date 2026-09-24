class AllowNullHerbIdOnTeaReviewHerbs < ActiveRecord::Migration[7.2]
  # 「その他」で自由入力したハーブは herb_id を持たず custom_herb_name のみを保存する。
  # View（new/edit/show）は既に herb_id が nil である前提で書かれているため、制約側を合わせる。
  def up
    change_column_null :tea_review_herbs, :herb_id, true
  end

  def down
    change_column_null :tea_review_herbs, :herb_id, false
  end
end
