module Sync
  class Base
    def self.sync_all
      Rails.application.eager_load!
      subclasses.each { _1.new.start }
    end

    def start
      response.each do |json|
        unique_key = unique_value(json)
        record = find_or_initialize_record(unique_key)
        params = update_params(json)
        record.update(params)
      end
    end

    private

    def response
      uri = URI(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new uri

      response = https.request(request)
      if response.is_a?(Net::HTTPOK)
        JSON.parse(response.body, symbolize_names: true)
      else
        raise "Could not contact #{model.to_s.downcase.pluralize(2)} API: #{response.class}"
      end
    end

    def find_or_initialize_record(value) = model.find_or_initialize_by(unique_field => value)

    def url = raise "Implement in subclass"

    def model = raise "Implement in subclass"

    def unique_field = raise "Implement in subclass"

    def unique_value(json) = raise "Implement in subclass"

    def update_params(json) = raise "Implement in subclass"
  end
end
