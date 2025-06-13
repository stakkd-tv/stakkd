module Importers::Tmdb
  class Person < Base
    private

    def endpoint = "person"

    def construct_params(json)
      {
        alias: "",
        biography: json[:biography],
        dob: json[:birthday] ? Date.parse(json[:birthday]) : nil,
        dod: json[:deathday] ? Date.parse(json[:deathday]) : nil,
        gender: ::Person::GENDERS[json[:gender]],
        imdb_id: json[:imdb_id],
        known_for: json[:known_for_department].downcase,
        translated_name: json[:name],
        original_name: json[:name]
      }
    end

    def model_class = ::Person

    def image_types
      {profiles: :images}
    end
  end
end
