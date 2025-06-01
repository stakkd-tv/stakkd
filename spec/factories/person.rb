FactoryBot.define do
  factory :person do
    biography { "This is a bio" }
    imdb_id { "nm0000192" }
    known_for { "acting" }
    original_name { "Test Name" }
    translated_name { "Test Name" }
    name_kebab { "" }
  end
end
