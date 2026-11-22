FactoryBot.define do
  factory :rating do
    user
    association :item, factory: [:movie, :with_release_date]
    score { 8 }
  end
end
