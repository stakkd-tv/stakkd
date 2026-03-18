require "rails_helper"

RSpec.describe ConfirmationToken, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { ConfirmationToken.create(user: FactoryBot.create(:user, :confirmed)) }

    it { should validate_presence_of(:token) }
    it { should validate_presence_of(:expires_at) }
    it { should validate_uniqueness_of(:token) }
  end

  describe "before_create :generate_token" do
    it "generates the token and expires at" do
      travel_to Time.current
      confirmation_token = ConfirmationToken.new
      confirmation_token.save
      expect(confirmation_token.token).not_to be_nil
      expect(confirmation_token.expires_at).to eq Time.current + 15.minutes
    end
  end

  describe ".active" do
    it "returns tokens that have not expired" do
      travel_to Time.current
      confirmation_token1 = ConfirmationToken.create(user: FactoryBot.create(:user, :confirmed))
      confirmation_token2 = ConfirmationToken.create(user: FactoryBot.create(:user, :confirmed))
      confirmation_token2.update(expires_at: Time.current - 1.minute)
      expect(ConfirmationToken.active).to eq [confirmation_token1]
    end
  end
end
