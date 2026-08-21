FactoryBot.define do
  factory :stack do
    user
    name { "My amazing stack" }

    trait :official do
      user { nil }
    end
  end
end
