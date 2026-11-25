module Manage
  class Ratings
    class InvalidRating < StandardError; end

    def initialize(user)
      @user = user
    end

    def set!(item, score:)
      validate_context!(item)
      score = parse_score!(score)

      @user.with_lock do
        ratings = ratings_for(item)
        rating = ratings.first
        next rating if rating&.score == score

        raise InvalidRating, "Cannot rate an unreleased item" unless item.released?

        rating ||= ratings.build
        rating.update!(score:)
        rating
      end
    end

    def remove!(item)
      validate_context!(item)

      @user.with_lock do
        ratings_for(item).delete_all
      end
    end

    def scores_for(items)
      return {} if !@user || items.empty?

      scores = @user.ratings.where(item: items).pluck(:item_type, :item_id, :score)
        .to_h { |type, id, score| [[type, id], score] }
      items.index_with { |item| scores[[item.class.polymorphic_name, item.id]] }
    end

    private

    def ratings_for(item)
      @user.ratings.where(item:)
    end

    def validate_context!(item)
      raise InvalidRating, "A persisted user is required" unless @user&.persisted?
      unless item&.persisted? && Rating::ITEM_TYPES.include?(item.class.polymorphic_name)
        raise InvalidRating, "A persisted movie, show, season or episode is required"
      end
    end

    def parse_score!(score)
      # Check the input before Active Record can coerce a fractional value.
      score = score.to_i if score.is_a?(String) && /\A(?:[1-9]|10)\z/.match?(score)
      unless score.is_a?(Integer) && Rating::SCORES.cover?(score)
        raise InvalidRating, "Score must be a whole number from 1 to 10"
      end

      score
    end
  end
end
