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

    trait :with_release_date do
      transient do
        date_for_release { Date.today }
      end

      after(:create) do |movie, evaluator|
        cert = Certification.find_by(country: movie.country) || create(:certification, country: movie.country)
        create(:release, movie:, type: Release::THEATRICAL, certification: cert, date: evaluator.date_for_release)
      end
    end
  end
end
