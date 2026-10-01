FactoryBot.define do
  factory :recipe_herb do
    recipe
    # モデルが herb_id の存在を検証するため、build でも herb は保存して id を持たせる
    association :herb, strategy: :create
    quantity { 2 }
    unit { :g }

    trait :custom do
      herb { nil }
      custom_herb_name { "庭のミント" }
    end
  end
end
