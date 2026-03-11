class Episode < ApplicationRecord
  include HasImdb

  TYPES = [
    STANDARD = "standard",
    MID_SEASON_FINALE = "mid-season finale",
    SEASON_FINALE = "season finale"
  ]

  # Assocations
  belongs_to :season
  has_many :guest_stars, -> { order(position: :asc) }, as: :record, class_name: "CastMember", dependent: :destroy
  has_many :crew_members, as: :record, dependent: :destroy
  has_many :videos, as: :record, dependent: :destroy
  has_one :show, through: :season
  has_many_attached :backgrounds

  # Validations
  validates :translated_name, :original_name, presence: true
  validates :number, uniqueness: {scope: [:season_id]}
  validates :number, numericality: {greater_than_or_equal_to: 1}
  validates :episode_type, inclusion: {in: TYPES}
  validates :runtime, numericality: {greater_than_or_equal_to: 0}

  # Scopes
  scope :ordered, -> { order(number: :asc) }
  scope :nested, ->(number) { where(number:) }

  def background = backgrounds.first || "16:9.png"

  def to_param = number.to_s

  # TODO: If the episode is the last episode in the season, check if there is a next season and
  # if there is, get the first episode of that season as the next episode.
  def next_episode = @next_episode ||= season.episodes.where(number: number + 1).first

  # TODO: If the episode is the first episode in the season, check if there is a previous season and
  # if there is, get the last episode of that season as the previous episode.
  def previous_episode = @previous_episode ||= season.episodes.where(number: number - 1).first

  def related_records = super.merge(season:, show:)

  def records_for_polymorphic_paths = [show, season, self]

  def directors = @directors ||= crew_members.includes(:job, :person).where(job: {name: Job::DIRECTOR})

  def writers = @writers ||= crew_members.includes(:job, :person).where(job: {name: Job::WRITER})

  def year = original_air_date&.year

  TYPES.each do |type|
    define_method "#{type}?" do
      episode_type == type
    end
  end
end
