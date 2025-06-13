require "net/http"
require "uri"

module Importers::Tmdb
  # A quick and easy way to import data on development machines from TMDB.
  # Usage:
  # - Open a rails console:
  #   `bin/rails c`
  # - Run the specific importer for the record you want:
  #   `Importers::Tmdb::Person.new(tmdb_id: 123).import`
  class Base
    def initialize(tmdb_id:)
      @tmdb_id = tmdb_id
    end

    def import
      data = response
      return unless data
      params = construct_params(data)
      record = model_class.create!(params)
      import_images(record, data[:images])
      record
    end

    private

    def import_images(record, images_hash)
      image_types.each_pair do |tmdb_field, stakkd_field|
        images = images_hash[tmdb_field]
        images.take(10).each do |image|
          file_path = image[:file_path]
          file_url = "https://image.tmdb.org/t/p/original#{file_path}"
          file = URI.open(file_url) # standard:disable Security/Open
          image = Rack::Test::UploadedFile.new(file.path, file.content_type)
          validator_class = Uploads::Validators::Base.for(klass: model_class, field: stakkd_field)
          u = Uploads::Upload.new(record:, field: stakkd_field, image:, validator_class:)
          u.validate_and_save!
        end
      end
    end

    def response
      uri = URI("https://api.themoviedb.org/3/#{endpoint}/#{@tmdb_id}?append_to_response=images&language=en")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new uri
      request["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwOGU2MWFlOWFhY2NlNDAzM2Q4MjM5ZjRkMDY1M2JiMCIsIm5iZiI6MTU4NDc5MzcyMC41MDcsInN1YiI6IjVlNzYwODc4MmYzYjE3MDAxMTUwZWU0OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.l9_OfIIwum4p17_cBa0r1LF6Jg7ZGLgiNdM1FE7I1KE"

      response = https.request(request)
      puts response
      response.is_a?(Net::HTTPOK) ? JSON.parse(response.body, symbolize_names: true) : nil
    end

    def endpoint = raise "Implement in subclass"

    def construct_params(json) = raise "Implement in subclass"

    def model_class = raise "Implement in subclass"

    def image_types = raise "Implement in subclass"
  end
end
