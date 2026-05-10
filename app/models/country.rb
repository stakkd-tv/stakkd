class Country < ApplicationRecord
  self.strict_loading_by_default = true

  # Associations
  has_many :certifications, dependent: :destroy

  # Validations
  validates_presence_of :code, :translated_name
  validates_uniqueness_of :code

  def flag = "https://flagsapi.com/#{code}/flat/64.png"
end
