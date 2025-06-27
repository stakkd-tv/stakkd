class Certification < ApplicationRecord
  MEDIA_TYPES = ["Movie", "Show"]

  # Associations
  belongs_to :country

  # Validations
  validates :media_type, inclusion: {in: MEDIA_TYPES}
  validates_presence_of :code, :description, :position

  # Scopes
  scope :for_movies, -> { where(media_type: "Movie") }

  def to_s = "#{country.code} - #{code}"
end
