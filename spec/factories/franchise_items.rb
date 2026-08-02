FactoryBot.define do
  factory :franchise_item do
    franchise
    association :record, factory: :movie
  end
end
