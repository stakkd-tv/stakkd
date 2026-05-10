class Language < ApplicationRecord
  # Validations
  validates_presence_of :code, :translated_name
  validates_uniqueness_of :code
end
