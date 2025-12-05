class Season < ApplicationRecord
  # Associations
  belongs_to :show

  # Validations
  validates :translated_name, :original_name, presence: true
  validates :number, uniqueness: {scope: [:show_id]}
end
