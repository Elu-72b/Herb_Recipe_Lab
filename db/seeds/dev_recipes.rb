# 開発・検証用のレシピデータ。
#
# 目的: Gemini レシピ提案機能の Finder（効能 AND × 風味 AND × 禁忌除外）と
#       公開/非公開スコープを、実データで検証できるようにする。
#
# 検証の観点ごとに、意図的に次のパターンを含めている。
#   - 「睡眠サポート × 甘味」でヒットし、禁忌を持たない公開レシピ（ヒットすべき）
#   - 同条件を満たすが「妊娠中注意」ハーブを含む公開レシピ（除外されるべき）
#   - 同条件を満たすが非公開のレシピ（public_recipes で除外されるべき）
#
# 前提: db/seeds/herbs.rb のハーブマスタとユーザーが投入済みであること。
DEV_RECIPES = [
  # ── 公開・睡眠系 ─────────────────────────────
  {
    title: "おやすみ前のまろやかブレンド",
    memo: "寝る前に飲むと落ち着く。甘さ控えめでまろやか。",
    is_public: true,
    amount: 300,
    herbs: [ [ "リンデン", 3, :g ], [ "レモンバーム", 2, :g ], [ "ルイボス", 2, :g ] ]
  },
  {
    title: "甘い夢のナイトティー",
    memo: "ステビアで甘みを足して飲みやすく。",
    is_public: true,
    amount: 250,
    herbs: [ [ "リンデン", 3, :g ], [ "ローズ", 1, :g ], [ "ステビア", 0.5, :g ] ]
  },
  {
    title: "カモミールの安眠ブレンド",
    memo: "定番の組み合わせ。妊娠中は避ける。",
    is_public: true,
    amount: 300,
    herbs: [ [ "カモミールジャーマン", 3, :g ], [ "リンデン", 2, :g ] ]
  },
  {
    title: "深い眠りのハーブ",
    memo: "バレリアンは香りが強いので少量で。",
    is_public: true,
    amount: 200,
    herbs: [ [ "バレリアン", 1, :teaspoon ], [ "パッションフラワー", 2, :teaspoon ] ]
  },
  # ── 公開・その他の系統 ───────────────────────
  {
    title: "ぽかぽか温活ジンジャー",
    memo: "冷える日の朝に。ジンジャーは少なめでも十分効く。",
    is_public: true,
    amount: 300,
    herbs: [ [ "ジンジャー", 1, :g ], [ "ルイボス", 3, :g ], [ "オレンジピール", 2, :g ] ]
  },
  {
    title: "うるおい美肌ブレンド",
    memo: "酸味が強いので蜂蜜を足しても良い。",
    is_public: true,
    amount: 300,
    herbs: [ [ "ローズヒップ", 3, :g ], [ "ハイビスカス", 2, :g ], [ "ローズ", 1, :g ] ]
  },
  {
    title: "すっきりリフレッシュミント",
    memo: "食後や気分を切り替えたいときに。",
    is_public: true,
    amount: 250,
    herbs: [ [ "ペパーミント", 2, :g ], [ "オレンジピール", 2, :g ] ]
  },
  # ── 非公開（public_recipes スコープの検証用）─────
  {
    title: "試作：おやすみリンデン",
    memo: "非公開。睡眠×甘味の条件を満たすが公開していない。",
    is_public: false,
    amount: 250,
    herbs: [ [ "リンデン", 3, :g ], [ "ステビア", 0.5, :g ] ]
  },
  {
    title: "試作：喉ケアブレンド",
    memo: "非公開。タイムの苦味が強いので調整中。",
    is_public: false,
    amount: 200,
    herbs: [ [ "タイム", 1, :g ], [ "リコリス", 0.5, :g ], [ "エルダーフラワー", 2, :g ] ]
  },
  {
    title: "試作：デトックスブレンド",
    memo: "非公開。苦味が強く飲みにくいので配合を検討中。",
    is_public: false,
    amount: 300,
    herbs: [ [ "ダンデライオン", 2, :g ], [ "ネトル", 2, :g ] ]
  }
].freeze

users = User.order(:id).to_a
if users.empty?
  puts "⚠ ユーザーが存在しないため、開発用レシピの投入をスキップしました"
else
  DEV_RECIPES.each_with_index do |data, index|
    owner = users[index % users.size]

    recipe = Recipe.find_or_initialize_by(user: owner, title: data[:title])
    recipe.assign_attributes(
      memo: data[:memo],
      is_public: data[:is_public],
      amount: data[:amount],
      brewed_at: Date.current - index.days
    )
    recipe.save!

    # 配合は seed を正として毎回作り直す（実行のたびに重複しないようにする）
    recipe.recipe_herbs.destroy_all
    data[:herbs].each do |herb_name, quantity, unit|
      herb = Herb.find_by(name: herb_name)
      if herb.nil?
        puts "  ⚠ #{data[:title]}: ハーブ「#{herb_name}」が見つかりません"
        next
      end

      recipe.recipe_herbs.create!(herb: herb, quantity: quantity, unit: unit)
    end
  end

  puts "開発用レシピ: #{DEV_RECIPES.size} 件を投入しました" \
       "（公開 #{Recipe.public_recipes.count} 件 / 全 #{Recipe.count} 件）"
end
