FactoryBot.define do
  factory :release do
    movie
    certification
    type { Release::THEATRICAL }
    date { "2025-06-21" }
  end
end
