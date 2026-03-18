FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "test#{n}@example.com" }
    password { "top-secret" }
    sequence(:username) { |n| "user#{n}" }

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
