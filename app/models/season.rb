class Season < ApplicationRecord
  # Associations
  belongs_to :show
  has_many :season_regulars, -> { order(position: :asc) }, as: :record, class_name: "CastMember", dependent: :destroy
  has_many :videos, as: :record, dependent: :destroy
  has_many :episodes, dependent: :destroy
  has_many :ordered_episodes, -> { ordered }, class_name: "Episode"
  has_many_attached :posters

  # Validations
  validates :translated_name, :original_name, presence: true
  validates :number, uniqueness: {scope: [:show_id]}
  validates :number, numericality: {greater_than_or_equal_to: 0}

  # Scopes
  scope :without_specials, -> { where.not(number: 0) }
  scope :ordered, -> { order(number: :asc) }
  scope :nested, ->(number) { where(number:) }

  def poster = posters.first || "2:3.png"

  def available_galleries = [:posters, :videos]

  def to_param = number.to_s

  def specials? = number.zero?

  def related_records
    super.merge(show:)
  end

  def to_s = "#{show} - Season #{number}"

  def runtime = episodes.sum(:runtime)

  def next_season = @next_season ||= show.seasons.where(number: number + 1).first

  def previous_season = @previous_season ||= show.seasons.where(number: number - 1).first
end
