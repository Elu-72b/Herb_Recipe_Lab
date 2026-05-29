class CreateTeaReviewHerbs < ActiveRecord::Migration[7.2]
  def change
    create_table :tea_review_herbs do |t|
      t.references :tea_review, null: false, foreign_key: true
      t.references :herb, null: false, foreign_key: true

      t.timestamps
    end
  end
end
