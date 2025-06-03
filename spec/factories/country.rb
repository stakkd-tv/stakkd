FactoryBot.define do
  factory :country do
    sequence(:code) { |n| "gb#{n}" }
    translated_name { "United Kingdom" }
    original_name { "United Kingdom" }
  end
end
