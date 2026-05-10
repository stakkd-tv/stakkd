class Language < ApplicationRecord
  self.strict_loading_by_default = true

  # Validations
  validates_presence_of :code, :translated_name
  validates_uniqueness_of :code
end
