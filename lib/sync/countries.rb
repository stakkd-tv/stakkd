require "net/http"

module Sync
  class Countries < Base
    private

    def url = "https://countries.petethompson.net/data/countries.json"

    def model = Country

    def unique_field = :code

    def unique_value(json) = json[:cca2]

    def update_params(json)
      {
        translated_name: json[:name][:common],
        original_name: json[:name][:native][:common]
      }
    end
  end
end
