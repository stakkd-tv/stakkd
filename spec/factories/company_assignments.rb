FactoryBot.define do
  factory :company_assignment do
    company
    association :record, factory: :movie
  end
end
