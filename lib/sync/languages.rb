require "net/http"

module Sync
  class Languages < Base
    private

    def url = "https://raw.githubusercontent.com/stakkd-tv/languages.json/refs/heads/main/data/data.json"

    def model = Language

    def unique_field = :code

    def unique_value(json) = json[:isoCode]

    def update_params(json)
      {
        translated_name: json[:name],
        original_name: json[:nativeName]
      }
    end
  end
end
