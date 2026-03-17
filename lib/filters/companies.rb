module Filters
  class Companies
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def filter
      companies = Company.includes(:country).order(:name)

      if country_id.present?
        companies = companies.where(country_id:)
      end

      companies.distinct
    end

    def to_params
      params = {}
      params[:country_id] = country_id if country_id.present?
      params
    end

    private

    def country_id = options[:country_id].present? ? options[:country_id].to_i : nil
  end
end
