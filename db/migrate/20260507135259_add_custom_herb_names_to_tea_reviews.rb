class AddCustomHerbNamesToTeaReviews < ActiveRecord::Migration[7.2]
  def change
    add_column :tea_reviews, :custom_herb_names, :string, array: true, default: []
  end
end
