FactoryBot.define do
  factory :collection_item do
    user
    association :item, factory: :movie
  end
end
