FactoryBot.define do
  factory :season do
    show
    number { 1 }
    translated_name { "Season 1" }
    original_name { "Season 1" }

    trait :with_premiere_date do
      transient do
        date_for_premiere { Date.today }
      end

      after(:create) do |season, evaluator|
        create(:episode, season:, number: 1, original_air_date: evaluator.date_for_premiere)
      end
    end
  end
end
