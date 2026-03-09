class Episode < ApplicationRecord
  TYPES = [
    STANDARD = "standard",
    MID_SEASON_FINALE = "mid-season finale",
    SEASON_FINALE = "season finale"
  ]

  # Assocations
  belongs_to :season
  has_many_attached :backgrounds

  # Validations
  validates :translated_name, :original_name, presence: true
  validates :number, uniqueness: {scope: [:season_id]}
  validates :number, numericality: {greater_than_or_equal_to: 1}
  validates :episode_type, inclusion: {in: TYPES}
  validates :runtime, numericality: {greater_than_or_equal_to: 0}

  # Scopes
  scope :ordered, -> { order(number: :asc) }

  def background = backgrounds.first || "16:9.png"

  TYPES.each do |type|
    define_method "#{type}?" do
      episode_type == type
    end
  end
end
