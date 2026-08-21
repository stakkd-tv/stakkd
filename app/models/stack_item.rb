class StackItem < ApplicationRecord
  acts_as_list scope: :item

  # Associations
  belongs_to :stack
  belongs_to :item, polymorphic: true

  # Validations
  validates_presence_of :added_at, :position
  validates_uniqueness_of :stack_id, scope: [:item_type, :item_id]
end
