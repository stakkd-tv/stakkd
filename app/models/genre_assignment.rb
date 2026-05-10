class GenreAssignment < ApplicationRecord
  # Associations
  belongs_to :genre
  belongs_to :record, polymorphic: true

  # Validations
  validates :genre_id, uniqueness: {scope: [:record_type, :record_id]}
end
