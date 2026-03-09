class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :sessions, dependent: :destroy

  # Validations
  validates_presence_of :username
  validates_uniqueness_of :email_address
  validates_uniqueness_of :username, case_sensitive: true
  validates :email_address, format: {with: URI::MailTo::EMAIL_REGEXP}

  before_validation :normalize_email

  def avatar = "https://github.com/stakkd-tv.png"

  private

  def normalize_email
    self.email_address = email_address.to_s.strip.downcase
  end
end
