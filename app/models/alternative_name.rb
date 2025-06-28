class AlternativeName < ApplicationRecord
  # Associations
  belongs_to :country
  belongs_to :record, polymorphic: true

  # Validations
  validates_presence_of :name

  def self.inheritance_column = nil
end
