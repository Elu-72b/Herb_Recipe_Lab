FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { Faker::Name.name }
    password { "password123" }

    trait :admin do
      admin { true }
    end
    trait :google do
      provider { "google_oauth2" }
      sequence(:uid) { |n| "google-uid-#{n}" }
    end
  end
end
