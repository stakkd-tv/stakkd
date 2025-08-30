module Filters
  class Movies
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def filter
      movies = Movie.order(:translated_title)

      movies = movies.where(country_id:) if country_id.present?

      if genre_ids.present?
        movies = movies.joins(:genres)
          .where(genres: {id: genre_ids})
          .group("movies.id")
          .having("COUNT(DISTINCT genres.id) = ?", genre_ids.size)
      end

      if release_date_from.present? && release_date_to.present?
        movies = movies.joins(:releases)
          .where(releases: {
            type: release_types,
            date: release_date_from..release_date_to
          })
      end

      movies.distinct
    end

    def to_params
      params = {}
      params[:country_id] = country_id if country_id.present?
      params[:genre_ids] = genre_ids if genre_ids.present?
      params[:release_date_from] = release_date_from.to_s if release_date_from.present?
      params[:release_date_to] = release_date_to.to_s if release_date_to.present?
      params[:release_type] = options[:release_type] if options[:release_type].present?
      params
    end

    private

    def release_types
      return Release::TYPES unless Release::TYPES.include?(options[:release_type])
      [options[:release_type]]
    end

    def release_date_from = try_parse_date(options[:release_date_from])

    def release_date_to = try_parse_date(options[:release_date_to])

    def genre_ids = options[:genre_ids]&.map(&:to_i)

    def country_id = options[:country_id].present? ? options[:country_id].to_i : nil

    def try_parse_date(date_string)
      Date.parse(date_string)
    rescue
      nil
    end
  end
end
