class Herb < ApplicationRecord
  belongs_to :user, optional: true
  has_one_attached :image

  has_many :herb_flavor_tags, dependent: :destroy
  has_many :flavor_tags, through: :herb_flavor_tags

  has_many :herb_functional_tags, dependent: :destroy
  has_many :functional_tags, through: :herb_functional_tags

  has_many :herb_caution_tags, dependent: :destroy
  has_many :caution_tags, through: :herb_caution_tags

  has_many :recipe_herbs, dependent: :destroy

  ACCEPTED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze

  validates :name, presence: true
  validates :image,
    content_type: ACCEPTED_CONTENT_TYPES,
    size: { less_than_or_equal_to: 5.megabytes },
    allow_blank: true
end
