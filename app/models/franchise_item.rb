class FranchiseItem < ApplicationRecord
  # Assocations
  belongs_to :franchise
  belongs_to :record, polymorphic: true

  # Validations
  validates :record_id, uniqueness: {scope: [:record_type]}

  # Callbacks
  before_validation :set_date

  # Scopes
  scope :ordered, -> { order(:date) }

  private

  def set_date
    self.date = record&.release_date
  end
end
