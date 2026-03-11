class Show < ApplicationRecord
  include Slugify
  include HasImdb

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
  has_many :videos, as: :record, dependent: :destroy
  has_many :seasons, dependent: :destroy
  has_many :ordered_seasons, -> { ordered }, class_name: "Season"
  has_many :seasons_without_specials, -> { without_specials }, class_name: "Season"
  has_many :non_special_episodes, through: :seasons_without_specials, source: :episodes
  has_many_attached :posters
  has_many_attached :backgrounds
  has_many_attached :logos

  # Validations
  validates_presence_of :translated_title, :original_title
  validates_inclusion_of :status, in: STATUSES
  validates_inclusion_of :type, in: TYPES

  # Callbacks
  after_create :create_specials_season

  def self.inheritance_column = nil

  def poster = posters.first || "2:3.png"

  def background = backgrounds.first

  def logo = logos.first || "1:1.png"

  def slug=(value)
    self.title_kebab = value
  end

  def to_s = translated_title

  def tagline = taglines.first&.tagline

  def available_galleries = [:posters, :backgrounds, :logos, :videos]

  def runtime = non_special_episodes.sum(:runtime)

  def cast_members = season_regulars # Duck typing for cast members controller

  def creators = @creators ||= crew_members.includes(:job, :person).where(job: {name: Job::CREATOR})

  def year = premiere_date&.year

  private

  def slug_source = translated_title

  def _slug = title_kebab

  def create_specials_season
    Season.create(show: self, number: 0, translated_name: "Specials", original_name: "Specials")
  end
end
