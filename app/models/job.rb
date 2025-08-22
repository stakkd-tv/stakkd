class Job < ApplicationRecord
  include PgSearch::Model

  DIRECTOR = "Director"

  pg_search_scope :search, against: [:department, :name], using: {trigram: {threshold: 0.2}}

  # Validations
  validates :name, :department, presence: true
end
