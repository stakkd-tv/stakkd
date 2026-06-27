class Person < ApplicationRecord
  include Typesense
  include Slugify
  include HasImdb
  include HasGalleries

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

  typesense do
    attributes :original_name, :translated_name

    # alias is used internally, so we use aka instead
    attribute :aka do
      self.alias.to_s
    end

    predefined_fields [
      {"name" => "original_name", "type" => "string"},
      {"name" => "translated_name", "type" => "string", "sort" => true},
      {"name" => "aka", "type" => "string"}
    ]
  end

  # Associations
  has_many :cast_credits, class_name: "CastMember", dependent: :destroy
  has_many :crew_credits, class_name: "CrewMember", dependent: :destroy
  has_galleries :images

  # Validations
  validates_presence_of :original_name, :translated_name, :name_kebab
  validates_inclusion_of :known_for, in: CREDITS, allow_blank: true, allow_nil: true
  validates_inclusion_of :gender, in: GENDERS

  def image_url(variant: nil)
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
    img = image(variant:, use_fallback: false)
    return unless img

    img = img.processed if variant.present? && img.respond_to?(:processed)
    img.url
  end

  def age
    return unless dob.present?
    end_date = dod.present? ? dod : Date.current
    ((end_date - dob).to_f / 365).to_i
  end

  def slug=(value)
    self.name_kebab = value
  end

  private

  def slug_source = translated_name

  def _slug = name_kebab
end
