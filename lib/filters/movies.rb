module Filters
  class Movies
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def filter
      movies = sort_movies

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

      if company_ids.present?
        movies = movies.joins(:companies)
          .where(companies: {id: company_ids})
          .group("movies.id")
          .having("COUNT(DISTINCT companies.id) = ?", company_ids.size)
      end

      if certification_ids.present?
        movies = movies.joins(:releases)
          .where(releases: {certification_id: certification_ids})
      end

      if keywords.present?
        movies = movies.tagged_with(keywords)
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
      params[:company_ids] = company_ids if company_ids.present?
      params[:certification_ids] = certification_ids if certification_ids.present?
      params[:keywords] = keywords if keywords.present?
      params[:sort] = sort[:value]
      params
    end

    def sorting_options = allowed_sorting_options.map { {name: it[:option_name], value: it[:value]} }

    private

    def release_types
      return Release::TYPES unless Release::TYPES.include?(options[:release_type])
      [options[:release_type]]
    end

    def release_date_from = try_parse_date(options[:release_date_from])

    def release_date_to = try_parse_date(options[:release_date_to])

    def genre_ids = options[:genre_ids]&.map(&:to_i)

    def country_id = options[:country_id].present? ? options[:country_id].to_i : nil

    def company_ids = options[:company_ids]&.map(&:to_i)

    def certification_ids = options[:certification_ids]&.compact_blank&.map(&:to_i)

    def keywords = options[:keywords]&.compact_blank

    def allowed_sorting_options
      [
        {option_name: "Title", value: "translated_title", order_by: :translated_title},
        {option_name: "Release Date", value: "release_date", order_by: :release_date},
        {option_name: "Popularity", value: "popularity"},
        {option_name: "Rating", value: "rating"}
      ]
    end

    def sort = allowed_sorting_options.find { it[:value] == options[:sort] } || allowed_sorting_options.first

    def sort_movies
      order_by = sort[:order_by]

      if order_by.is_a?(Symbol)
        Movie.order(order_by)
      else
        # TODO: Support lambda function so we can sort on anonymous fields such as rating or popularity
        Movie
      end
    end

    def try_parse_date(date_string)
      Date.parse(date_string)
    rescue
      nil
    end
  end
end
