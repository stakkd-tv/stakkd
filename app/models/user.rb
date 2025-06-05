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

  def avatar = "https://images-ext-1.discordapp.net/external/OLDoJ_5ghf4ERpLvexzWkavmoWH24ec56Dp_CCmLrFw/%3Fsize%3D512/https/cdn.discordapp.com/avatars/450284404481327105/a1c683e2de3734c41ea77ff710aaad2a.png?format=webp&quality=lossless"

  private

  def normalize_email
    self.email_address = email_address.to_s.strip.downcase
  end
end
