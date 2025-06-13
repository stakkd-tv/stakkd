class Movie < ApplicationRecord
  include Slugify

  STATUSES = [
    RUMORED = "rumored",
    PLANNED = "planned",
    IN_PRODUCTION = "in production",
    POST_PRODUCTION = "post production",
    RELEASED = "released",
    CANCELLED = "cancelled"
  ]

  # Associations
  belongs_to :country
  belongs_to :language
  has_many :alternative_names, as: :record, dependent: :delete_all
  has_many_attached :posters
  has_many_attached :backgrounds
  has_many_attached :logos

  # Validations
  validates_presence_of :translated_title, :original_title, :runtime, :revenue, :budget
  validates_inclusion_of :status, in: STATUSES

  def poster = posters.first || "2:3.png"

  def background = backgrounds.first

  def logo = logos.first || "1:1.png"

  def imdb_url = "https://www.imdb.com/name/#{imdb_id}/"

  def slug=(value)
    self.title_kebab = value
  end

  def to_s = translated_title

  private

  def slug_source = translated_title

  def _slug = title_kebab
end
