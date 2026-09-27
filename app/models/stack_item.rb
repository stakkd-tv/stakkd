class StackItem < ApplicationRecord
  acts_as_list scope: :stack

  SORT_MAP = {
    "Movie" => {title: :translated_title, release_date: :release_date},
    "Show" => {title: :translated_title, release_date: :premiere_date},
    "Season" => {title: :translated_name, release_date: :premiere_date},
    "Episode" => {title: :translated_name, release_date: :original_air_date}
  }.freeze

  # Associations
  belongs_to :stack
  belongs_to :item, polymorphic: true

  # Validations
  validates_presence_of :added_at, :position
  validates_uniqueness_of :stack_id, scope: [:item_type, :item_id]

  # Scopes
  scope :first_three_per_stack, -> {
    ranked = select(<<~SQL)
      stack_items.*,
      ROW_NUMBER() OVER (
        PARTITION BY stack_id
        ORDER BY added_at ASC
      ) AS stack_item_rank
    SQL

    from("(#{ranked.to_sql}) stack_items")
      .where("stack_item_rank <= 3")
      .order("stack_item_rank ASC")
  }
  scope :ordered_by_position, ->(direction = :asc) { order(position: direction) }
  scope :ordered_by_added_at, ->(direction = :asc) { order(added_at: direction) }
  scope :ordered_by_title, ->(direction = :asc) { ordered_by_item_field(:title, direction) }
  scope :ordered_by_release_date, ->(direction = :asc) { ordered_by_item_field(:release_date, direction) }
  # TODO: Do actual implementation for these and calculate runtime for shows and seasons
  scope :ordered_by_runtime, ->(direction = :asc) { ordered_by_position(direction) }
  scope :ordered_by_popularity, ->(direction = :asc) { ordered_by_position(direction) }
  scope :ordered_by_overall_rating, ->(direction = :asc) { ordered_by_position(direction) }
  # Scope factory for sort map
  scope :ordered_by_item_field, ->(field, direction = :asc) {
    sql = SORT_MAP.map do |type, fields|
      table = type.constantize.table_name
      column = fields.fetch(field)

      <<~SQL.squish
        WHEN #{connection.quote(type)} THEN (
          SELECT #{column}
          FROM #{table}
          WHERE #{table}.id = stack_items.item_id
        )
      SQL
    end.join(" ")

    order(
      Arel.sql("CASE item_type #{sql} END #{direction.to_s.upcase} NULLS LAST")
    )
  }
end
