class Company < ApplicationRecord
  include Slugify
  include HasGalleries

  # Associations
  belongs_to :country
  has_many :company_assignments, dependent: :destroy
  has_galleries :logos

  # Validations
  validates_presence_of :name, :name_kebab

  def logo_url
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
    logo.try(:url)
  end

  def slug=(value)
    self.name_kebab = value
  end

  private

  def slug_source = name

  def _slug = name_kebab
end
