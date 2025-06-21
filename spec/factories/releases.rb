FactoryBot.define do
  factory :release do
    movie
    certification
    language
    type { "Theatrical" }
    date { "2025-06-21" }
  end
end
