FactoryBot.define do
  factory :video do
    source_key { "dQw4w9WgXcQ" }
    source { "YouTube" }
    type { "Trailer" }
    name { "Never Gonna Give You Up" }
    association :record, factory: :movie
  end
end
