require "rails_helper"

RSpec.describe User, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "associations" do
    it { should have_many(:sessions).dependent(:destroy) }
    it { should have_many(:confirmation_tokens).dependent(:destroy) }
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

  describe ".stale" do
    it "returns users who have not confirmed within 30 days" do
      travel_to Time.current
      FactoryBot.create(:user, :confirmed)
      FactoryBot.create(:user)
      user1 = FactoryBot.create(:user, created_at: 31.days.ago)
      user2 = FactoryBot.create(:user, created_at: 30.days.ago)
      FactoryBot.create(:user, created_at: 29.days.ago)
      expect(User.stale).to contain_exactly(user1, user2)
    end
  end

  describe ".needing_confirmation_reminder" do
    it "returns users who have not confirmed within 20 days but does not return any older than 30 days" do
      travel_to Time.current
      FactoryBot.create(:user, :confirmed)
      FactoryBot.create(:user)
      FactoryBot.create(:user, created_at: 31.days.ago)
      FactoryBot.create(:user, created_at: 30.days.ago)
      user1 = FactoryBot.create(:user, created_at: 29.days.ago)
      user2 = FactoryBot.create(:user, created_at: 21.days.ago)
      FactoryBot.create(:user, created_at: 21.days.ago, confirmation_reminder_sent_at: Time.current)
      user3 = FactoryBot.create(:user, created_at: 20.days.ago)
      FactoryBot.create(:user, created_at: 19.days.ago)
      expect(User.needing_confirmation_reminder).to contain_exactly(user1, user2, user3)
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
