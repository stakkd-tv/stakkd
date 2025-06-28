class Video < ApplicationRecord
  SOURCES = ["YouTube", "Vimeo"]
  TYPES = [
    "Trailer",
    "Teaser",
    "Clip",
    "Behind the Scenes",
    "Bloopers",
    "Featurette",
    "Opening Theme",
    "Ending Theme"
  ]

  # Associations
  belongs_to :record, polymorphic: true

  # Validations
  validates_presence_of :name, :source, :source_key, :type
  validates_inclusion_of :source, in: SOURCES
  validates_inclusion_of :type, in: TYPES

  def self.inheritance_column = nil
end
