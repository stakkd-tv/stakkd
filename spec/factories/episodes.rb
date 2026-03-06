FactoryBot.define do
  factory :episode do
    season
    translated_name { "Episode 1" }
    original_name { "Episode 1" }
    overview { "Greatest episode of all time" }
    original_air_date { Date.new(2026, 3, 6) }
    number { 1 }
    episode_type { Episode::STANDARD }
    runtime { 25 }
    production_code { "101" }
  end
end
