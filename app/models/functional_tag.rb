class FunctionalTag < ApplicationRecord
  CATEGORIES = {
    "心・自律神経" => ["リラックス（鎮静）", "睡眠サポート", "ストレス緩和", "集中力向上", "気分リフレッシュ"],
    "消化・代謝"   => ["消化促進", "胃腸ケア", "食欲調整", "デトックス", "利尿作用", "整腸作用", "血糖値サポート"],
    "症状ケア"     => ["抗炎症", "抗酸化", "抗菌", "抗アレルギー", "鎮痙作用", "喉ケア"],
    "免疫・循環"   => ["免疫サポート", "血行促進", "発汗作用", "冷え対策", "ホルモンバランス"],
    "美容・栄養"   => ["美肌ケア", "ミネラル補給", "エイジングケア"],
    "活力・疲労"   => ["疲労回復", "眼精疲労サポート", "滋養補給"]
  }.freeze

  def self.grouped_by_category
    all_tags = all.index_by(&:name)
    CATEGORIES.transform_values do |names|
      names.filter_map { |name| all_tags[name] }
    end
  end
end
