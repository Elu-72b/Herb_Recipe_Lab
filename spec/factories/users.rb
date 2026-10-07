FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { Faker::Name.name }
    password { "password123" }
    confirmed_at { Time.current }

    trait :admin do
      admin { true }
    end
    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end
