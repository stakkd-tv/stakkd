class Rating < ApplicationRecord
  ITEM_TYPES = %w[Movie Show Season Episode].freeze
  SCORES = 1..10

  belongs_to :user
  belongs_to :item, polymorphic: true

  validates :item_type, inclusion: {in: ITEM_TYPES}
  validates :item_id, uniqueness: {scope: [:user_id, :item_type]}
  validates :score, numericality: {only_integer: true, in: SCORES}
end
