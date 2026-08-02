module Filters
  class Franchises
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def filter
      franchises = Franchise
        .left_joins(:franchise_items)
        .select("franchises.*, COUNT(franchise_items.id) AS items_count")
        .group("franchises.id")
        .order(:translated_title)

      if release_dates_from.present? && release_dates_to.present?
        franchises = franchises
          .joins(:franchise_items)
          .where(franchise_items: {date: release_dates_from..release_dates_to})
      end

      franchises.distinct
    end

    def to_params
      params = {}
      params[:release_dates_from] = release_dates_from.to_s if release_dates_from.present?
      params[:release_dates_to] = release_dates_to.to_s if release_dates_to.present?
      params
    end

    private

    def release_dates_from = try_parse_date(options[:release_dates_from])

    def release_dates_to = try_parse_date(options[:release_dates_to])

    def try_parse_date(date_string)
      Date.parse(date_string)
    rescue
      nil
    end
  end
end
