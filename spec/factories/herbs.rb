FactoryBot.define do
  factory :herb do
    sequence(:name) { |n| "テストハーブ#{n}" }
    user { nil } # マスタハーブは user なし。ユーザー登録ハーブは association で上書きする
  end
end
