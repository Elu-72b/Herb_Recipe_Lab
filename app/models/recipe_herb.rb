class RecipeHerb < ApplicationRecord
  belongs_to :recipe
  belongs_to :herb

  # seeds.rbのunit設計に合わせた定義
  enum :unit, { g: 0, teaspoon: 1, piece: 2, individual: 3 }

  validates :quantity, presence: true,
    numericality: { greater_than: 0, message: "配合量は0より大きい値を入力してください" }
  validates :herb_id, presence: { message: "ハーブを選択してください" }
end