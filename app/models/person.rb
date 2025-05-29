class Person < ApplicationRecord
  # Associations
  has_many_attached :images

  # Validations
  validates_presence_of :original_name, :translated_name

  def image = images.first || "2:3.png"

  def age
    return unless dob.present?
    end_date = dod.present? ? dod : Date.current
    ((end_date - dob).to_f / 365).to_i
  end

  def imdb_url = "https://www.imdb.com/name/#{imdb_id}/"
end
