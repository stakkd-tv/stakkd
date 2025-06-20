FactoryBot.define do
  factory :tagline do
    tagline { "Amazing tagline!" }
    association :record, factory: :movie
  end
end
