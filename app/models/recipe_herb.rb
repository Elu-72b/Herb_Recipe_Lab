class RecipeHerb < ApplicationRecord
  belongs_to :recipe
  belongs_to :herb, optional: true

  def self.ransackable_attributes(auth_object = nil)
    %w[custom_herb_name]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[herb]
  end

  # seeds.rbのunit設計に合わせた定義
  enum :unit, { teaspoon: 0, tablespoon: 1, g: 2, piece: 3, individual: 4 }

  # "other"をARが0にキャストするため、カスタムハーブ選択時はnilに正規化する
  before_validation :normalize_other_herb_id

  validates :quantity, presence: true,
    numericality: { greater_than: 0, message: "は0より大きい値を入力してください" }
  validates :herb_id, presence: { message: "を選択してください" }, if: -> { custom_herb_name.blank? }
  validates :custom_herb_name, presence: { message: "を入力してください" }, if: -> { herb_id.nil? }

  private

  def normalize_other_herb_id
    self.herb_id = nil if herb_id == 0
  end
end