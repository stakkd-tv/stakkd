FactoryBot.define do
  factory :crew_member do
    association :record, factory: :movie
    person
    job
  end
end
