class Company < ApplicationRecord
  include HasGalleries

  # Associations
  belongs_to :country
  has_many :company_assignments, dependent: :destroy
  has_galleries :logos

  # Validations
  validates_presence_of :name

  def logo_url
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
    logo.try(:url)
  end

  # TODO: Add slug to companies
  def self.from_slug(id)
    find(id)
  end
end
