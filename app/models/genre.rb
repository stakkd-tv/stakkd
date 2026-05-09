class Genre < ApplicationRecord
  self.strict_loading_by_default = true

  # Associations
  has_many :genre_assignments, dependent: :destroy
  has_many :movies, through: :genre_assignments, source: :record, source_type: "Movie"
  has_many :shows, through: :genre_assignments, source: :record, source_type: "Show"

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name
end
