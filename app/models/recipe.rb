# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :user
  has_many :recipe_herbs, dependent: :destroy
  has_many :herbs, through: :recipe_herbs
  has_one :drinking_log, dependent: :destroy

  has_and_belongs_to_many :flavor_tags
  has_and_belongs_to_many :functional_tags

  has_many :bookmarks, dependent: :destroy

  validates :title, presence: true
  validates :brewed_at, presence: true

  scope :public_recipes, -> { where(is_public: true) }
  scope :recent, -> { order(created_at: :desc) }
end
