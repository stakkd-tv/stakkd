FactoryBot.define do
  factory :history_item do
    consumed_at { "2026-08-07 19:56:11" }
    user
    association :item, factory: :movie
  end
end
