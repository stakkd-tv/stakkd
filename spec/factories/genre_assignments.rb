FactoryBot.define do
  factory :genre_assignment do
    genre
    association :record, factory: :movie
  end
end
