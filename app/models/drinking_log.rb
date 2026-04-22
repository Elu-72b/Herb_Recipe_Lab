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

  validates :rating, presence: true, inclusion: { in: 1..5 }
  
  # すべての味覚パラメータ（0〜5）を検証
  FLAVOR_MAPPING.values.each do |column|
    validates column, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  end
end
