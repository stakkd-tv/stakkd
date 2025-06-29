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

  # Callbacks
  before_validation :set_details_from_source, on: :create

  def self.inheritance_column = nil

  def url = source_instance.video_url

  def source_icon = source_instance.icon

  private

  def source_instance = @source_instance ||= Videos::Source.for(source, source_key)

  def set_details_from_source
    self.name = source_instance.title
    self.thumbnail_url = source_instance.thumbnail_url
  end
end
