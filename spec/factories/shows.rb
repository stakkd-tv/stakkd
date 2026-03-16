FactoryBot.define do
  factory :show do
    language
    country
    homepage { "https://google.com" }
    imdb_id { "tt" }
    original_title { "Breaking Bad" }
    overview { "Breaking Bad overview" }
    status { "ended" }
    translated_title { "Breaking Bad" }
    title_kebab { "breaking-bad" }
    type { "series" }

    trait :with_premiere_date do
      transient do
        date_for_premiere { Date.today }
      end

      after(:create) do |show, evaluator|
        create(:season, :with_premiere_date, date_for_premiere: evaluator.date_for_premiere, show:, number: 1)
      end
    end
  end
end
