class Company < ApplicationRecord
  # Associations
  belongs_to :country
  has_many_attached :logos

  # Validations
  validates_presence_of :name

  def logo = logos.first || "1:1.png"

  def logo_url
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
    logo.try(:url)
  end

  def available_galleries = [:logos]

  # TODO: Add slug to companies
  def self.from_slug(id)
    find(id)
  end
end
