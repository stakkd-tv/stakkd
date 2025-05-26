require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:sessions).dependent(:destroy) }
  end

  describe "validations" do
    subject { User.create(email_address: "test@example.com", username: "Obi", password: "hello") }
    it { should have_secure_password }
    it { should validate_uniqueness_of(:email_address).case_insensitive }
    it { should validate_uniqueness_of(:username) }
  end

  describe "before_validation :normalize_email" do
    it "normalizes the email address" do
      user = User.new(email_address: "HELLO@THERE.COM", username: "hehe", password: "hehe")
      user.save!
      expect(user.reload.email_address).to eq "hello@there.com"
    end
  end
end
