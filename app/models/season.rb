class Season < ApplicationRecord
  # Associations
  belongs_to :show
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

  def available_galleries = [:posters]

  def to_param = number.to_s

  def specials? = number.zero?

  def related_records
    super.merge(show:)
  end

  def to_s = "#{show} - Season #{number}"
end
