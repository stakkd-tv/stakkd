class Release < ApplicationRecord
  # Associations
  belongs_to :movie
  belongs_to :certification
  belongs_to :language

  # Validations
  validates_presence_of :type, :date
end
