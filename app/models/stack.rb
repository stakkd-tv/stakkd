class Stack < ApplicationRecord
  TYPES = [
    "standard",
    "watchlist",
    "collection"
  ]

  SORTING_METHODS = [
    "added_at",
    "position",
    "release_date"
    # TODO: Popularities and ratings (community (avg) and user (your own))
  ]

  # Associations
  belongs_to :user, optional: true
  has_many :stack_items, dependent: :delete_all

  # Validations
  validates_presence_of :name
  validates_inclusion_of :type, in: TYPES
  validates_inclusion_of :sorting_method, in: SORTING_METHODS

  # Scopes
  scope :official, -> { where(user_id: nil) }

  def self.inheritance_column = nil

  def add!(item, added_at: Time.current)
    StackItem.create!(
      stack: self,
      item:,
      added_at:
    )
  end

  def remove!(item)
    stack_item = stack_items.find_by!(item:)
    stack_item.destroy
  end
end
