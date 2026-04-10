require "rails_helper"

RSpec.describe User, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "associations" do
    it { should belong_to(:banned_by).class_name("User").optional(true) }
    it { should have_many(:sessions).dependent(:destroy) }
    it { should have_many(:confirmation_tokens).dependent(:destroy) }
    it { should have_one_attached(:profile_picture) }
    it { should have_one_attached(:background) }
  end

  describe "validations" do
    subject { User.create(email_address: "test@example.com", username: "Obi", password: "hello") }
    it { should have_secure_password }
    it { should validate_uniqueness_of(:email_address).case_insensitive }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_presence_of(:username) }
    it { should_not validate_presence_of(:ban_reason) }

    context "when banned_at is present" do
      subject { FactoryBot.build(:user, banned_at: Time.current) }

      it { should validate_presence_of(:ban_reason) }
    end
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

  describe ".from_username" do
    it "returns the user with the given username" do
      user = FactoryBot.create(:user, username: "testuser")
      found = User.from_username("testuser")
      expect(found).to eq user
    end

    it "returns nil for a non-existent username" do
      found = User.from_username("nonexistent")
      expect(found).to be_nil
    end

    it "ignores case when searching by username" do
      user = FactoryBot.create(:user, username: "testuser")
      found = User.from_username("TESTUSER")
      expect(found).to eq user
    end
  end

  describe "#to_param" do
    it "returns the username" do
      user = FactoryBot.create(:user, username: "test")
      expect(user.to_param).to eq "test"
    end
  end

  describe "#avatar" do
    context "when the user has a profile picture" do
      it "returns the profile picture" do
        user = FactoryBot.create(:user, profile_picture: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec", "support", "assets", "300x450.png"), "image/png"))
        expect(user.avatar).to be_a(ActiveStorage::Attached::One)
      end
    end

    context "when the user has no avatar" do
      it "returns a placeholder profile picture" do
        user = FactoryBot.create(:user)
        expect(user.avatar).to eq "user.png"
      end
    end
  end

  describe "#hero" do
    context "when the user has a background" do
      it "returns the background" do
        user = FactoryBot.create(:user, background: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec", "support", "assets", "300x450.png"), "image/png"))
        expect(user.hero).to be_a(ActiveStorage::Attached::One)
      end
    end

    context "when the user has no background" do
      it "returns a placeholder background" do
        user = FactoryBot.create(:user)
        expect(user.hero).to eq "16:9.png"
      end
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

  describe "#ban!" do
    it "bans the user and sets the ban reason" do
      travel_to Time.current
      user = FactoryBot.create(:user)
      user.ban!(reason: "spam")
      expect(user.banned?).to be_truthy
      expect(user.ban_reason).to eq "spam"
      expect(user.banned_at).to eq Time.current
    end

    it "sets the banned_by relationship" do
      user = FactoryBot.create(:user)
      banned_by = FactoryBot.create(:user)
      user.ban!(reason: "spam", banned_by:)
      expect(user.banned_by).to eq banned_by
    end
  end

  describe "#banned?" do
    it "returns true for banned users" do
      user = FactoryBot.create(:user, banned_at: Time.current, ban_reason: "Test")
      expect(user.banned?).to be_truthy
    end

    it "returns false for banned users" do
      user = FactoryBot.create(:user, banned_at: nil)
      expect(user.banned?).to be_falsey
    end
  end

  describe "#active?" do
    it "returns true for confirmed, not banned users" do
      user = FactoryBot.create(:user, :confirmed)
      expect(user.active?).to be_truthy
    end

    it "returns false for unconfirmed, not banned users" do
      user = FactoryBot.create(:user)
      expect(user.active?).to be_falsey
    end

    it "returns false for confirmed, banned users" do
      user = FactoryBot.create(:user, :confirmed, banned_at: Time.current, ban_reason: "Test")
      expect(user.active?).to be_falsey
    end

    it "returns false for unconfirmed, banned users" do
      user = FactoryBot.create(:user, banned_at: Time.current, ban_reason: "Test")
      expect(user.active?).to be_falsey
    end
  end
end
