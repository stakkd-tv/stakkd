class Release < ApplicationRecord
  TYPES = [
    PREMIERE = "Premiere",
    LIMITED_THEATRICAL = "Limited Theatrical",
    THEATRICAL = "Theatrical",
    DIGITAL = "Digital",
    PHYSICAL = "Physical",
    TV = "TV"
  ]

  # Associations
  belongs_to :movie
  belongs_to :certification
  has_one :country, through: :certification

  # Validations
  validates_presence_of :type, :date
  validates_inclusion_of :type, in: TYPES

  # Callbacks
  after_save :trigger_movie_update

  def self.inheritance_column = nil

  private

  def trigger_movie_update
    movie.save
  end
end
