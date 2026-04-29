class DrinkingLog < ApplicationRecord
  belongs_to :recipe

  # 風味タグ名（seeds.rb）とDBカラム名のマッピング
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

  before_validation :normalize_zero_flavors

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
end
