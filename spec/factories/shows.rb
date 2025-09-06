FactoryBot.define do
  factory :show do
    language
    country
    homepage { "https://google.com" }
    imdb_id { "tt" }
    original_title { "Breaking Bad" }
    overview { "Breaking Bad overview" }
    runtime { 45 }
    status { "ended" }
    translated_title { "Breaking Bad" }
    title_kebab { "breaking-bad" }
    type { "series" }
  end
end
