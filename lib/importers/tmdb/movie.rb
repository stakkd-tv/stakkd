module Importers::Tmdb
  class Movie < Base
    private

    def endpoint = "movie"

    def construct_params(json)
      {
        language: language(json[:original_language]),
        country: country(json[:origin_country].first || ""),
        original_title: json[:original_title],
        translated_title: json[:title],
        overview: json[:overview],
        status: json[:status].downcase,
        runtime: json[:runtime],
        revenue: json[:revenue],
        budget: json[:budget],
        homepage: json[:homepage],
        imdb_id: json[:imdb_id]
      }
    end

    def model_class = ::Movie

    def image_types
      {posters: :posters, backdrops: :backgrounds}
    end

    def language(code)
      Language.find_by(code:)
    end

    def country(code)
      Country.find_by(code:)
    end
  end
end
