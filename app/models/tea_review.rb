class TeaReview < ApplicationRecord
  belongs_to :user
  belongs_to :herb, optional: true
  has_many :tea_review_herbs, dependent: :destroy
  has_many :herbs, through: :tea_review_herbs
  accepts_nested_attributes_for :tea_review_herbs,
    allow_destroy: true,
    reject_if: :all_blank

  FLAVOR_MAPPING = {
    "甘味" => :sweetness,
    "酸味" => :acidity,
    "苦味" => :bitterness,
    "渋味" => :astringency,
    "フルーティー" => :fruity,
    "スパイシー" => :spicy,
    "清涼感" => :freshness,
    "華やかさ" => :flowery
  }.freeze

  before_validation :normalize_zero_flavors, :compact_custom_herb_names

  validates :brand, presence: true
  validates :name, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }

  FLAVOR_MAPPING.values.each do |column|
    validates column, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  end

  private

  def normalize_zero_flavors
    FLAVOR_MAPPING.values.each do |col|
      send(:"#{col}=", nil) if send(col) == 0
    end
  end

  def compact_custom_herb_names
    self.custom_herb_names = Array(custom_herb_names).map(&:strip).reject(&:blank?)
  end
end
