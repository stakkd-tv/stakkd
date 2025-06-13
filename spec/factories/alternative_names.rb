FactoryBot.define do
  factory :alternative_name do
    name { "MyString" }
    type { "" }
    country
    association :record, factory: :movie
  end
end
