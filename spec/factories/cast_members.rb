FactoryBot.define do
  factory :cast_member do
    association :record, factory: :movie
    person
    character { "Obi Wan Kenobi" }
    position { 1 }
  end
end
