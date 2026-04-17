class User < ApplicationRecord
  USERNAME_EXCLUSIONS = ["me", "admin"].freeze

  has_secure_password

  # Associations
  belongs_to :banned_by, class_name: "User", optional: true
  has_many :sessions, dependent: :destroy
  has_many :confirmation_tokens, dependent: :destroy
  has_one_attached :profile_picture
  has_one_attached :background

  # Validations
  validates_presence_of :username
  validates_presence_of :ban_reason, if: :banned_at?
  validates_uniqueness_of :email_address
  # User CRXSSED is the same as the user crxssed
  validates_uniqueness_of :username, case_sensitive: false
  validates :username, format: {
    with: /\A[a-zA-Z0-9_]+\z/,
    message: "can only contain letters, numbers, and underscores"
  }
  validates :email_address, format: {with: URI::MailTo::EMAIL_REGEXP}
  validate :username_exclusions

  # Callbacks
  before_validation :normalize_email

  # Scopes
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :stale, -> { where(confirmed_at: nil, created_at: ..30.days.ago) }
  scope :needing_confirmation_reminder, -> { where(confirmation_reminder_sent_at: nil, confirmed_at: nil, created_at: 29.days.ago..20.days.ago) }

  def self.from_username(username)
    username = username.to_s.downcase
    User.where("LOWER(username) = ?", username).first
  end

  def to_param = username

  def avatar = profile_picture.attached? ? profile_picture : "user.png"

  def hero = background.attached? ? background : "16:9.png"

  def confirmed? = confirmed_at.present?

  def ban!(reason:, banned_by: nil)
    update(banned_at: Time.current, ban_reason: reason, banned_by:)
  end

  def banned? = banned_at.present?

  def active? = !banned? && confirmed?

  private

  def username_exclusions
    return unless username.present? # Username presence is validated anyway
    if USERNAME_EXCLUSIONS.include?(username.downcase)
      errors.add(:username, "cannot be one of #{USERNAME_EXCLUSIONS.join(", ")}")
    end
  end

  def normalize_email
    self.email_address = email_address.to_s.strip.downcase
  end
end
