class ContentRating < ApplicationRecord
  # Associations
  belongs_to :show
  belongs_to :certification

  # Validations
  validates_uniqueness_of :show_id, scope: [:certification_id]
end
