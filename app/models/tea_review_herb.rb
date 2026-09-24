class TeaReviewHerb < ApplicationRecord
  belongs_to :tea_review
  belongs_to :herb, optional: true

  # "other"をARが0にキャストするため、カスタムハーブ選択時はnilに正規化する
  before_validation :normalize_other_herb_id

  validates :herb_id, presence: { message: "を選択してください" }, if: -> { custom_herb_name.blank? }
  validates :custom_herb_name, presence: { message: "を入力してください" }, if: -> { herb_id.nil? }

  private

  def normalize_other_herb_id
    self.herb_id = nil if herb_id == 0
  end
end
