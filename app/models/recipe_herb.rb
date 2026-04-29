class RecipeHerb < ApplicationRecord
  belongs_to :recipe
  belongs_to :herb, optional: true

  # seeds.rbのunit設計に合わせた定義
  enum :unit, { teaspoon: 0, tablespoon: 1, g: 2, piece: 3, individual: 4 }

  # "other"をARが0にキャストするため、カスタムハーブ選択時はnilに正規化する
  before_validation :normalize_other_herb_id

  validates :quantity, presence: true,
    numericality: { greater_than: 0, message: "配合量は0より大きい値を入力してください" }
  validates :herb_id, presence: { message: "ハーブを選択してください" }, if: -> { custom_herb_name.blank? }
  validates :custom_herb_name, presence: { message: "ハーブ名を入力してください" }, if: -> { herb_id.nil? }

  private

  def normalize_other_herb_id
    self.herb_id = nil if herb_id == 0
  end
end