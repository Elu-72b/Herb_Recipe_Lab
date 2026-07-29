# ハーブマスタ（名前 → 説明 / 風味 / 効能 / 禁忌タグ）
#
# 前提: 風味・効能・禁忌の各タグは db/seeds.rb で作成済みであること。
# 方針: このファイルを「ハーブマスタの唯一の正」とする。
#   - ハーブ本体は find_or_create_by! で冪等に作成する。
#   - タグは代入（上書き）で同期し、手作業でついた不正確な紐付けを残さない。
#   - 一覧に無い既存ハーブ（ユーザーが画面から登録したもの等）には触れない。
#     Herb は dependent: :destroy で recipe_herbs を連鎖削除するため、削除は行わない。
HERB_SEEDS = [
  {
    name: "カモミールジャーマン",
    description: "りんごのような甘い香り。心と胃腸をゆるめる代表的なリラックスハーブ。",
    flavors: %w[甘味 まろやかさ 華やかさ],
    functions: [ "リラックス（鎮静）", "睡眠サポート", "胃腸ケア" ],
    cautions: %w[妊娠中注意 アレルギー注意]
  },
  {
    name: "カモミールローマン",
    description: "ジャーマンより苦味が強く、香りが濃い。少量をブレンドに加えると香りが引き締まる。",
    flavors: %w[苦味 華やかさ],
    functions: [ "リラックス（鎮静）", "鎮痙作用" ],
    cautions: %w[妊娠中注意 アレルギー注意]
  },
  {
    name: "ラベンダー",
    description: "清涼感のある花の香り。緊張をほぐし眠りへ導く。入れすぎると苦味が出る。",
    flavors: %w[華やかさ 苦味],
    functions: [ "リラックス（鎮静）", "ストレス緩和", "睡眠サポート" ],
    cautions: %w[妊娠中注意]
  },
  {
    name: "レモンバーム",
    description: "やさしいレモンの香り。神経性の胃の不調にも用いられる。",
    flavors: %w[清涼感 酸味 まろやかさ],
    functions: [ "リラックス（鎮静）", "ストレス緩和", "胃腸ケア" ],
    cautions: []
  },
  {
    name: "リンデン",
    description: "ほんのり甘くまろやか。就寝前のブレンドのベースに向く。",
    flavors: %w[甘味 まろやかさ],
    functions: [ "リラックス（鎮静）", "睡眠サポート", "発汗作用" ],
    cautions: []
  },
  {
    name: "パッションフラワー",
    description: "「植物性のトランキライザー」とも呼ばれる穏やかな鎮静ハーブ。",
    flavors: %w[まろやかさ],
    functions: [ "睡眠サポート", "リラックス（鎮静）" ],
    cautions: %w[妊娠中注意 鎮静作用あり]
  },
  {
    name: "バレリアン",
    description: "独特の強い香りと苦味。少量で深い休息をサポートする。",
    flavors: %w[苦味],
    functions: [ "睡眠サポート", "リラックス（鎮静）" ],
    cautions: %w[薬剤服用中注意 鎮静作用あり]
  },
  {
    name: "ペパーミント",
    description: "強い清涼感。食後の重さや気分の切り替えに。",
    flavors: %w[清涼感],
    functions: [ "消化促進", "胃腸ケア", "気分リフレッシュ" ],
    cautions: %w[小児使用注意]
  },
  {
    name: "ローズヒップ",
    description: "ビタミンCが豊富で酸味が強い。ハイビスカスと好相性。",
    flavors: %w[酸味 フルーティー],
    functions: [ "美肌ケア", "免疫サポート", "抗酸化" ],
    cautions: []
  },
  {
    name: "ハイビスカス",
    description: "鮮やかな赤色と強い酸味。運動後の疲労回復に。",
    flavors: %w[酸味 フルーティー],
    functions: [ "疲労回復", "利尿作用" ],
    cautions: %w[低血圧注意 利尿作用あり]
  },
  {
    name: "ルイボス",
    description: "ノンカフェインでクセが少なく、ブレンドのベースにしやすい。",
    flavors: %w[まろやかさ 甘味],
    functions: [ "抗酸化", "整腸作用", "冷え対策" ],
    cautions: []
  },
  {
    name: "ローズ",
    description: "華やかな香りで気分を高める。女性向けブレンドの定番。",
    flavors: %w[華やかさ 甘味],
    functions: [ "ストレス緩和", "ホルモンバランス", "美肌ケア" ],
    cautions: %w[ホルモン感受性注意]
  },
  {
    name: "リコリス",
    description: "砂糖の数十倍の甘さ。ごく少量で全体をまとめる甘味役。",
    flavors: %w[甘味],
    functions: [ "喉ケア", "抗炎症" ],
    cautions: %w[高血圧注意 妊娠中注意]
  },
  {
    name: "ジンジャー",
    description: "体を温めるスパイス。冷え対策ブレンドの主役。",
    flavors: %w[スパイシー],
    functions: [ "血行促進", "冷え対策", "消化促進" ],
    cautions: %w[妊娠中注意 抗凝固薬注意]
  },
  {
    name: "ネトル",
    description: "緑茶に似た渋みとミネラル感。春先の不調ケアに用いられる。",
    flavors: %w[渋味],
    functions: [ "ミネラル補給", "抗アレルギー" ],
    cautions: %w[利尿作用あり]
  },
  {
    name: "エルダーフラワー",
    description: "マスカットのような香り。風邪のひきはじめの定番。",
    flavors: %w[華やかさ 甘味],
    functions: [ "免疫サポート", "発汗作用" ],
    cautions: []
  },
  {
    name: "オレンジピール",
    description: "柑橘の甘い香りで飲みやすさを底上げする名脇役。",
    flavors: %w[フルーティー 甘味],
    functions: [ "気分リフレッシュ", "消化促進" ],
    cautions: %w[光感作注意]
  },
  {
    name: "ステビア",
    description: "低カロリーの強い甘味。砂糖の代わりに極少量で使う。",
    flavors: %w[甘味],
    functions: [ "血糖値サポート" ],
    cautions: []
  },
  {
    name: "エキナセア",
    description: "ネイティブアメリカン伝統の免疫ハーブ。季節の変わり目に。",
    flavors: %w[苦味 渋味],
    functions: [ "免疫サポート", "抗ウイルス", "抗菌" ],
    cautions: %w[アレルギー注意 薬剤服用中注意]
  },
  {
    name: "ダンデライオン",
    description: "根を焙煎するとコーヒーに似た風味。むくみケアに。",
    flavors: %w[苦味],
    functions: [ "デトックス", "利尿作用", "整腸作用" ],
    cautions: %w[利尿作用あり アレルギー注意]
  },
  {
    name: "ローリエ",
    description: "料理でおなじみの月桂樹。すっきりした香りで食後に。",
    flavors: %w[スパイシー 苦味],
    functions: [ "消化促進", "食欲調整" ],
    cautions: %w[妊娠中注意]
  },
  {
    name: "タイム",
    description: "強い抗菌力で知られる。喉の不調時のブレンドに。",
    flavors: %w[スパイシー 苦味],
    functions: [ "抗菌", "喉ケア", "抗ウイルス" ],
    cautions: %w[妊娠中注意]
  }
].freeze

# タグ名から実レコードを引く。未登録の名前は警告して気づけるようにする。
def fetch_tags(klass, names, herb_name)
  return [] if names.blank?

  found = klass.where(name: names).to_a
  missing = names - found.map(&:name)
  puts "  ⚠ #{herb_name}: 未登録タグ #{missing.join('、')}（#{klass.name}）" if missing.any?

  found
end

HERB_SEEDS.each do |data|
  herb = Herb.find_or_create_by!(name: data[:name])
  herb.update!(description: data[:description])
  herb.flavor_tags     = fetch_tags(FlavorTag,     data[:flavors],   data[:name])
  herb.functional_tags = fetch_tags(FunctionalTag, data[:functions], data[:name])
  herb.caution_tags    = fetch_tags(CautionTag,    data[:cautions],  data[:name])
end

puts "ハーブマスタ: #{HERB_SEEDS.size} 件を投入しました（Herb.count = #{Herb.count}）"
