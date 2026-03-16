module Filters
  class Shows
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def filter
      shows = Show.order(:translated_title)

      shows = shows.where(country_id:) if country_id.present?

      if premiere_date_from.present? && premiere_date_to.present?
        shows = shows.where(premiere_date: premiere_date_from..premiere_date_to)
      end

      if episode_air_date_from.present? && episode_air_date_to.present?
        shows = shows
          .joins(:non_special_episodes)
          .where(non_special_episodes: {original_air_date: episode_air_date_from..episode_air_date_to})
      end

      if genre_ids.present?
        shows = shows.joins(:genres)
          .where(genres: {id: genre_ids})
          .group("shows.id")
          .having("COUNT(DISTINCT genres.id) = ?", genre_ids.size)
      end

      if company_ids.present?
        shows = shows.joins(:companies)
          .where(companies: {id: company_ids})
          .group("shows.id")
          .having("COUNT(DISTINCT companies.id) = ?", company_ids.size)
      end

      if certification_ids.present?
        shows = shows.joins(:content_ratings)
          .where(content_ratings: {certification_id: certification_ids})
      end

      if keywords.present?
        shows = shows.tagged_with(keywords)
      end

      shows.distinct
    end

    def to_params
      params = {}
      params[:country_id] = country_id if country_id.present?
      params[:genre_ids] = genre_ids if genre_ids.present?
      params[:company_ids] = company_ids if company_ids.present?
      params[:certification_ids] = certification_ids if certification_ids.present?
      params[:premiere_date_to] = premiere_date_to.to_s if premiere_date_to.present?
      params[:premiere_date_from] = premiere_date_from.to_s if premiere_date_from.present?
      params[:episode_air_date_from] = episode_air_date_from.to_s if episode_air_date_from.present?
      params[:episode_air_date_to] = episode_air_date_to.to_s if episode_air_date_to.present?
      params[:keywords] = keywords if keywords.present?
      params
    end

    private

    def country_id = options[:country_id].present? ? options[:country_id].to_i : nil

    def premiere_date_from = try_parse_date(options[:premiere_date_from])

    def premiere_date_to = try_parse_date(options[:premiere_date_to])

    def episode_air_date_from = try_parse_date(options[:episode_air_date_from])

    def episode_air_date_to = try_parse_date(options[:episode_air_date_to])

    def genre_ids = options[:genre_ids]&.map(&:to_i)

    def company_ids = options[:company_ids]&.map(&:to_i)

    def certification_ids = options[:certification_ids]&.compact_blank&.map(&:to_i)

    def keywords = options[:keywords]&.compact_blank

    def try_parse_date(date_string)
      Date.parse(date_string)
    rescue
      nil
    end
  end
end
