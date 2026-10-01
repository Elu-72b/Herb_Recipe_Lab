FactoryBot.define do
  factory :recipe do
    user
    sequence(:title) { |n| "テストブレンド#{n}" }
    brewed_at { Date.current }
    is_public { false }

    trait :public do
      is_public { true }
    end
  end
end
