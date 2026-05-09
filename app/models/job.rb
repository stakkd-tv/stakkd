class Job < ApplicationRecord
  include PgSearch::Model

  self.strict_loading_by_default = true

  DIRECTOR = "Director"
  CREATOR = "Creator"
  WRITER = "Writer"

  pg_search_scope :search, against: [:department, :name], using: {trigram: {threshold: 0.2}}

  # Validations
  validates :name, :department, presence: true
end
