class ConfirmationToken < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Callbacks
  before_validation :generate_token, on: :create

  private

  def generate_token
    self.expires_at = 15.minutes.from_now
    self.token ||= loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless self.class.exists?(token: random_token)
    end
  end
end
