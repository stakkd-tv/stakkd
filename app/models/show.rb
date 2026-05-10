class Show < ApplicationRecord
  include Slugify
  include HasImdb
  include HasGalleries

  acts_as_taggable_on :keywords

  STATUSES = [
    RETURNING = "returning",
    PLANNED = "planned",
    IN_PRODUCTION = "in production",
    ENDED = "ended",
    CANCELLED = "cancelled"
  ]

  TYPES = [
    DOCUMENTARY = "documentary",
    NEWS = "news",
    MINISERIES = "miniseries",
    REALITY = "reality",
    SERIES = "series",
    TALK_SHOW = "talk show",
    VIDEO = "video"
  ]

  # Associations
  belongs_to :language
  belongs_to :country
  has_many :alternative_names, as: :record, dependent: :destroy
  has_many :season_regulars, -> { order(position: :asc) }, as: :record, class_name: "CastMember", dependent: :destroy
  has_many :crew_members, as: :record, dependent: :destroy
  has_many :content_ratings, dependent: :destroy
  has_many :genre_assignments, as: :record, dependent: :destroy
  has_many :genres, -> { order(name: :asc) }, through: :genre_assignments
  has_many :company_assignments, as: :record, dependent: :destroy
  has_many :companies, through: :company_assignments
  has_many :taglines, -> { order(position: :asc) }, as: :record, dependent: :destroy
  has_many :seasons, dependent: :destroy
  has_many :ordered_seasons, -> { ordered }, class_name: "Season"
  has_many :seasons_without_specials, -> { without_specials }, class_name: "Season"
  has_many :non_special_episodes, through: :seasons_without_specials, source: :episodes
  has_many :episodes, through: :seasons
  has_galleries :posters, :backgrounds, :logos, :videos
  # TODO: Acts as taggable on does not seem to support strict loading. Keep an eye on
  # https://github.com/mbleigh/acts-as-taggable-on/issues/1176 and update this if it
  # is ever fixed.
  has_many :taggings, as: :taggable, dependent: :destroy, class_name: "::ActsAsTaggableOn::Tagging", strict_loading: false
  has_many :base_tags, through: :taggings, source: :tag, class_name: "::ActsAsTaggableOn::Tag", strict_loading: false

  # Validations
  validates_presence_of :translated_title, :original_title
  validates_inclusion_of :status, in: STATUSES
  validates_inclusion_of :type, in: TYPES

  # Callbacks
  after_create :create_specials_season

  def self.inheritance_column = nil

  def slug=(value)
    self.title_kebab = value
  end

  def to_s = translated_title

  def tagline = taglines.first&.tagline

  def runtime = non_special_episodes.sum(:runtime)

  def cast_members = season_regulars # Duck typing for cast members controller

  def creators = @creators ||= crew_members.includes(:job, :person).where(job: {name: Job::CREATOR})

  def year = premiere_date&.year

  def latest_season_number = seasons.maximum(:number) || 0

  private

  def slug_source = translated_title

  def _slug = title_kebab

  def create_specials_season
    seasons.create(number: 0, translated_name: "Specials", original_name: "Specials")
  end
end
