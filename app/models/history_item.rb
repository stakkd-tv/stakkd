class HistoryItem < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :item, polymorphic: true

  # Scopes
  scope :recently_consumed, -> { order(Arel.sql("consumed_at DESC NULLS LAST")) }
end
