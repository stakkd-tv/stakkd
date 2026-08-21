FactoryBot.define do
  factory :stack_item do
    stack
    association :item, factory: :movie
    added_at { Time.current }
  end
end
