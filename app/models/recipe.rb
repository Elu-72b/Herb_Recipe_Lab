# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :user
  has_many :recipe_herbs, dependent: :destroy
  has_many :herbs, through: :recipe_herbs
  has_one :drinking_log, dependent: :destroy

  has_and_belongs_to_many :flavor_tags
  has_and_belongs_to_many :functional_tags

  accepts_nested_attributes_for :recipe_herbs,
    allow_destroy: true,
    reject_if: :all_blank  # herb_idも量も空の行は無視する

  validates :title, presence: { message: "レシピ名を入力してください" }
  validates :brewed_at, presence: { message: "作成日を入力してください" }

  scope :public_recipes, -> { where(is_public: true) }
  scope :recent, -> { order(created_at: :desc) }
end
