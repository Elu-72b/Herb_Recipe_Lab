FactoryBot.define do
  factory :tea_review do
    user
    brand { "テストメーカー" }
    sequence(:name) { |n| "テストブレンド#{n}" }
    rating { 4 }
  end
end
