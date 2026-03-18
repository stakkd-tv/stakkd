class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :sessions, dependent: :destroy
  has_many :confirmation_tokens, dependent: :destroy

  # Validations
  validates_presence_of :username
  validates_uniqueness_of :email_address
  validates_uniqueness_of :username, case_sensitive: true
  validates :email_address, format: {with: URI::MailTo::EMAIL_REGEXP}

  # Callbacks
  before_validation :normalize_email

  # Scopes
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :stale, -> { where(confirmed_at: nil, created_at: ..30.days.ago) }
  scope :needing_confirmation_reminder, -> { where(confirmation_reminder_sent_at: nil, confirmed_at: nil, created_at: 29.days.ago..20.days.ago) }

  def avatar = "https://github.com/stakkd-tv.png"

  def confirmed? = confirmed_at.present?

  private

  def normalize_email
    self.email_address = email_address.to_s.strip.downcase
  end
end
