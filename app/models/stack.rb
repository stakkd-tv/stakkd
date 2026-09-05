class Stack < ApplicationRecord
  include Slugify

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
  validates_length_of :description, maximum: 100

  # Scopes
  scope :official, -> { where(user_id: nil) }
  scope :standard, -> { where(type: "standard") }
  scope :visible_to, ->(user) {
    joins(:user).where(
      "NOT stacks.private AND NOT users.private OR stacks.user_id = :user_id",
      user_id: user&.id
    )
  }

  def self.inheritance_column = nil

  def private?
    return false unless user # Official stacks are always public
    private || user.private
  end

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

  def slug=(value)
    self.name_kebab = value
  end

  def to_s = name

  def official? = user.nil?

  private

  def slug_source = name

  def _slug = name_kebab
end
