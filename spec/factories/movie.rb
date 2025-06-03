FactoryBot.define do
  factory :movie do
    language
    country
    original_title { "Back to the Future" }
    translated_title { "Back to the Future" }
    overview { "This is an overview" }
    status { "released" }
    runtime { 100 }
    revenue { 100000000 }
    budget { 100000000 }
    homepage { "https://google.com" }
    imdb_id { "tt" }
    title_kebab { "" }
  end
end
