module Ratings
  class Query
    # Each continuation condition follows the same ordering as its sort. Keep
    # them together so changes to sorting also account for later batches.
    SORTS = {
      "recent" => {
        label: "Recently rated",
        order: {updated_at: :desc, id: :desc},
        after: "(updated_at, id) < (:updated_at, :id)"
      },
      "oldest" => {
        label: "Oldest ratings",
        order: {updated_at: :asc, id: :asc},
        after: "(updated_at, id) > (:updated_at, :id)"
      },
      "highest" => {
        label: "Highest rated",
        order: {score: :desc, updated_at: :desc, id: :desc},
        after: "(score, updated_at, id) < (:score, :updated_at, :id)"
      },
      "lowest" => {
        label: "Lowest rated",
        order: {score: :asc, updated_at: :desc, id: :desc},
        after: "score > :score OR (score = :score AND (updated_at, id) < (:updated_at, :id))"
      }
    }.freeze

    attr_reader :hidden_media_types, :score, :sort

    def initialize(user, params = {})
      @user = user
      @hidden_media_types = Array(params[:hidden_media_types]) & Rating::ITEM_TYPES
      @score = params[:score].to_s.presence_in(Rating::SCORES.map(&:to_s))
      @sort = params[:sort].presence_in(SORTS.keys) || "recent"
      @hide_dates = params[:hide_dates].to_s == "true"
      @cursor = cursor_verifier.verified(params[:after].to_s)
    end

    def to_params = {hidden_media_types:, score:, sort:, hide_dates: @hide_dates}

    def filtered? = hidden_media_types.any? || score.present?

    def self.chronological_sorts = SORTS.reject { |_, config| config.fetch(:order).key?(:score) }.keys

    def chronological? = self.class.chronological_sorts.include?(sort)

    def show_dates? = chronological? && !@hide_dates

    def fetch(per_page:)
      ratings = apply_cursor(filtered_ratings)
        .order(SORTS.fetch(sort).fetch(:order))
        .preload(:item).limit(per_page + 1).to_a

      # Fetch one extra row to detect another batch without a separate count.
      has_more = ratings.size > per_page
      ratings = ratings.first(per_page)
      next_cursor = cursor_for(ratings.last) if has_more

      preload_card_associations(ratings)
      [ratings, next_cursor]
    end

    private

    def filtered_ratings
      ratings = @user.ratings.where(item_type: Rating::ITEM_TYPES - hidden_media_types)
      ratings = ratings.where(score:) if score
      ratings
    end

    def cursor_verifier = Rails.application.message_verifier("ratings-pagination")

    def cursor_for(rating)
      # Save values, not just an ID: the boundary must survive edits and removal.
      cursor_verifier.generate({"sort" => sort, "score" => rating.score, "updated_at" => rating.updated_at.iso8601(6), "id" => rating.id})
    end

    def apply_cursor(ratings)
      return ratings unless @cursor && @cursor["sort"] == sort

      boundary = @cursor.symbolize_keys.slice(:updated_at, :id, :score)
      ratings.where(SORTS.fetch(sort).fetch(:after), boundary)
    end

    def preload_card_associations(ratings)
      ratings.group_by(&:item_type).each do |type, entries|
        associations = case type
        when "Episode" then [:show, {season: [:show, {posters_attachments: :blob}]}]
        when "Season" then [:show, {posters_attachments: :blob}]
        else {posters_attachments: :blob}
        end

        ActiveRecord::Associations::Preloader.new(records: entries.map(&:item), associations:).call
      end
    end
  end
end
