class Season < ApplicationRecord
  include HasGalleries

  # Associations
  belongs_to :show
  has_many :season_regulars, -> { order(position: :asc) }, as: :record, class_name: "CastMember", dependent: :destroy
  has_many :episodes, dependent: :destroy
  has_many :ordered_episodes, -> { ordered }, class_name: "Episode"
  has_galleries :posters, :videos

  # Validations
  validates :translated_name, :original_name, presence: true
  validates :number, uniqueness: {scope: [:show_id]}
  validates :number, numericality: {greater_than_or_equal_to: 0}

  # Callbacks
  after_save :set_show_premiere_date

  # Scopes
  scope :without_specials, -> { where.not(number: 0).ordered }
  scope :ordered, -> { order(number: :asc) }
  scope :nested, ->(number) { where(number:) }

  def to_param = number.to_s

  def specials? = number.zero?

  def related_records
    super.merge(show:)
  end

  def records_for_polymorphic_paths = [show, self]

  def to_s = "#{show} - Season #{number}"

  def runtime = episodes.sum(:runtime)

  def next_season = @next_season ||= show.seasons.where(number: number + 1).first

  def previous_season = @previous_season ||= show.seasons.where(number: number - 1).first

  def year = premiere_date&.year

  private

  def set_show_premiere_date
    if show.seasons_without_specials.first == self
      show.update(premiere_date: premiere_date)
    end
  end
end
