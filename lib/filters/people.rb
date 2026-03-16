module Filters
  class People
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def filter
      people = Person.order(:translated_name)

      if gender.present?
        people = people.where(gender:)
      end

      if known_for.present?
        people = people.where(known_for:)
      end

      if birthday_from.present? && birthday_to.present?
        people = people.where(dob: birthday_from..birthday_to)
      end

      people.distinct
    end

    def to_params
      params = {}
      params[:birthday_to] = birthday_to.to_s if birthday_to.present?
      params[:birthday_from] = birthday_from.to_s if birthday_from.present?
      params[:gender] = gender if gender.present?
      params[:known_for] = known_for if known_for.present?
      params
    end

    private

    def birthday_from = try_parse_date(options[:birthday_from])

    def birthday_to = try_parse_date(options[:birthday_to])

    def gender = options[:gender]

    def known_for = options[:known_for]

    def try_parse_date(date_string)
      Date.parse(date_string)
    rescue
      nil
    end
  end
end
