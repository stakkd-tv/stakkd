class Certification < ApplicationRecord
  MEDIA_TYPES = ["Movie", "Show"]

  # Associations
  belongs_to :country

  # Validations
  validates :media_type, inclusion: {in: MEDIA_TYPES}
  validates_presence_of :code, :description, :position
end
