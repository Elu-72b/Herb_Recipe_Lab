class CautionTag < ApplicationRecord
  CATEGORIES = {
    "ライフステージ" => ["妊娠中注意", "授乳中注意", "小児使用注意", "高齢者注意"],
    "既往症・体質"   => ["高血圧注意", "低血圧注意", "糖尿病注意", "アレルギー注意"],
    "臓器機能"       => ["肝機能低下時注意", "腎機能低下時注意"],
    "作用特性"       => ["ホルモン感受性注意", "鎮静作用あり", "光感作注意", "利尿作用あり"],
    "相互作用"       => ["薬剤服用中注意", "抗凝固薬注意"]
  }.freeze

  def self.grouped_by_category
    all_tags = all.index_by(&:name)
    CATEGORIES.transform_values do |names|
      names.filter_map { |name| all_tags[name] }
    end
  end
end
