FactoryBot.define do
  factory :certification do
    media_type { "Movie" }
    country
    code { "MyString" }
    description { "MyString" }
    position { 1 }
  end
end
