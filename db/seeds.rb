# 風味タグ
flavor_names = %w[甘味 酸味 苦味 渋味 フルーティー スパイシー 清涼感 華やかさ]
flavor_names.each { |name| FlavorTag.find_or_create_by!(name: name) }

# 効能タグ
functional_names = [
  "リラックス（鎮静）", "睡眠サポート", "ストレス緩和", "集中力向上",
  "消化促進", "胃腸ケア", "食欲調整", "デトックス",
  "抗炎症", "抗酸化", "免疫サポート", "血行促進",
  "ホルモンバランス", "美肌ケア"
]
functional_names.each { |name| FunctionalTag.find_or_create_by!(name: name) }

caution_names = [
  "妊娠中注意", "授乳中注意", "小児使用注意",
  "高血圧注意", "低血圧注意", "糖尿病注意",
  "アレルギー注意", "肝機能低下時注意", "腎機能低下時注意",
  "ホルモン感受性注意", "鎮静作用あり", "光感作注意"
]
caution_names.each { |name| CautionTag.find_or_create_by!(name: name) }
