module Rateable
  extend ActiveSupport::Concern

  included do
    has_many :ratings, as: :item, dependent: :delete_all

    # These calculated attributes are available on records loaded through this scope.
    # Correlate each aggregate to use the ratings item index even for nested routes.
    # Aggregate before joining so other associations cannot multiply votes.
    scope :with_rating_summary, -> {
      summaries = Rating.where(item_type: polymorphic_name)
        .where("ratings.item_id = #{quoted_table_name}.id")
        .select("AVG(score) AS average_rating, COUNT(*) AS ratings_count")

      # Without GROUP BY, the aggregate returns one row even for unrated items.
      summary_join = <<~SQL.squish
        CROSS JOIN LATERAL (#{summaries.to_sql}) AS rating_summaries
      SQL

      joins(summary_join).select(
        "#{quoted_table_name}.*",
        "rating_summaries.average_rating AS average_rating",
        "rating_summaries.ratings_count AS ratings_count"
      )
    }
  end
end
