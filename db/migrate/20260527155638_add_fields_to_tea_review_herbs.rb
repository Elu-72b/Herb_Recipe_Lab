class AddFieldsToTeaReviewHerbs < ActiveRecord::Migration[7.2]
  def change
    add_column :tea_review_herbs, :quantity, :decimal
    add_column :tea_review_herbs, :unit, :string
    add_column :tea_review_herbs, :custom_herb_name, :string
  end
end
