FactoryBot.define do
  factory :video do
    name { "MyString" }
    source_key { "dQw4w9WgXcQ" }
    source { "YouTube" }
    type { "Trailer" }
    association :record, factory: :movie
  end
end
