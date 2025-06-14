class Genre < ApplicationRecord
  # Associations
  has_many :genre_assignments, dependent: :destroy
  has_many :movies, through: :genre_assignments, source: :record, source_type: "Movie"

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name
end
