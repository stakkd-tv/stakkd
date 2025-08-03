class Job < ApplicationRecord
  # Validations
  validates :name, :department, presence: true
end
