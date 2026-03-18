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
    it { should validate_presence_of(:username) }
  end

  describe "before_validation :normalize_email" do
    it "normalizes the email address" do
      user = User.new(email_address: "HELLO@THERE.COM", username: "hehe", password: "hehe")
      user.save!
      expect(user.reload.email_address).to eq "hello@there.com"
    end
  end

  describe ".confirmed" do
    it "only returns confirmed users" do
      user = FactoryBot.create(:user, :confirmed)
      FactoryBot.create(:user)
      expect(User.confirmed).to eq [user]
    end
  end

  describe "#avatar" do
    it "returns a temporary avatar" do
      user = User.new(username: "hehe", password: "hehe")
      expect(user.avatar).to eq "https://github.com/stakkd-tv.png"
    end
  end

  describe "#confirmed?" do
    it "returns true for confirmed users" do
      user = FactoryBot.create(:user, :confirmed)
      expect(user.confirmed?).to be_truthy
    end

    it "returns false for unconfirmed users" do
      user = FactoryBot.create(:user)
      expect(user.confirmed?).to be_falsey
    end
  end
end
