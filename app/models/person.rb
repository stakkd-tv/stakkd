class Person < ApplicationRecord
  include Slugify

  CREDITS = [
    WRITING = "writing",
    ACTING = "acting",
    DIRECTING = "directing",
    ART = "art",
    CREATOR = "creator",
    PRODUCTION = "production",
    VFX = "visual effects",
    SOUND = "sound"
  ]

  GENDERS = [
    UNKNOWN = "unknown",
    FEMALE = "female",
    MALE = "male",
    NON_BINARY = "non-binary"
  ]

  # Associations
  has_many_attached :images

  # Validations
  validates_presence_of :original_name, :translated_name, :name_kebab
  validates_inclusion_of :known_for, in: CREDITS, allow_blank: true, allow_nil: true
  validates_inclusion_of :gender, in: GENDERS

  def image = images.first || "2:3.png"

  def age
    return unless dob.present?
    end_date = dod.present? ? dod : Date.current
    ((end_date - dob).to_f / 365).to_i
  end

  def imdb_url = "https://www.imdb.com/name/#{imdb_id}/"

  def slug=(value)
    self.name_kebab = value
  end

  private

  def slug_source = translated_name

  def _slug = name_kebab
end
