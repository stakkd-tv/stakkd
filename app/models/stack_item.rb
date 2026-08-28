class StackItem < ApplicationRecord
  acts_as_list scope: :item

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
end
