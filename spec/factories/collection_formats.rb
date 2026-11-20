FactoryBot.define do
  factory :collection_format do
    user
    name { "VHS" }

    trait :common do
      user { nil }
      name { "Blu-ray" }
    end
  end
end
