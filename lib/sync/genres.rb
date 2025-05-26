module Sync
  class Genres < Base
    private

    def url = "https://raw.githubusercontent.com/stakkd-tv/genres.json/refs/heads/main/genres.json"

    def model = Genre

    def unique_field = :name

    def unique_value(json) = json[:name]

    def update_params(json)
      {
        name: json[:name]
      }
    end
  end
end
