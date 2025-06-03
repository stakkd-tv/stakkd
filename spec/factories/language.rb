FactoryBot.define do
  factory :language do
    sequence(:code) { |n| "en#{n}" }
    translated_name { "English" }
    original_name { "English" }
  end
end
