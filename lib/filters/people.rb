module Filters
  class People
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def filter
      people = sort_people

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
      params[:sort] = sort[:value]
      params
    end

    def sorting_options = allowed_sorting_options.map { {name: it[:option_name], value: it[:value]} }

    private

    def birthday_from = try_parse_date(options[:birthday_from])

    def birthday_to = try_parse_date(options[:birthday_to])

    def gender = options[:gender]

    def known_for = options[:known_for]

    def allowed_sorting_options
      [
        {option_name: "Name", value: "translated_name", order_by: :translated_name},
        {option_name: "Age", value: "age", order_by: method(:age_order_by)},
        {option_name: "Popularity", value: "popularity"}
      ]
    end

    def sort = allowed_sorting_options.find { it[:value] == options[:sort] } || allowed_sorting_options.first

    def sort_people
      order_by = sort[:order_by]

      if order_by.is_a?(Symbol)
        Person.order(order_by)
      elsif order_by.is_a?(Method)
        order_by.call
      else
        # TODO: Support lambda function so we can sort on anonymous fields such as rating or popularity
        Person
      end
    end

    def age_order_by
      Person.select(
        "people.*,
        CASE
          WHEN dob IS NULL THEN NULL
          ELSE EXTRACT(YEAR FROM AGE(COALESCE(dod, CURRENT_DATE), dob))
        END AS age"
      ).order(:age)
    end

    def try_parse_date(date_string)
      Date.parse(date_string)
    rescue
      nil
    end
  end
end
