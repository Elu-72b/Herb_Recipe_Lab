# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :user
  has_many :recipe_herbs, dependent: :destroy
  has_many :herbs, through: :recipe_herbs
  has_one :drinking_log, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  has_and_belongs_to_many :flavor_tags
  has_and_belongs_to_many :functional_tags

  accepts_nested_attributes_for :recipe_herbs,
    allow_destroy: true,
    reject_if: :all_blank  # herb_idも量も空の行は無視する

  validates :title, presence: { message: "を入力してください" }
  validates :brewed_at, presence: { message: "を入力してください" }

  scope :public_recipes, -> { where(is_public: true) }
  scope :visible_to, ->(user) {
    where("is_public = ? OR user_id = ?", true, user.id)
  }
  scope :recent, -> { order(created_at: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    %w[title created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[recipe_herbs user drinking_log flavor_tags functional_tags]
  end
end
