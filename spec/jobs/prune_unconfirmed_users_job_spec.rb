require "rails_helper"

RSpec.describe PruneUnconfirmedUsersJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  it "destroys all expired confirmation tokens" do
    user = FactoryBot.create(:user)
    ConfirmationToken.create!(user: user).update(expires_at: 1.minute.ago)
    ConfirmationToken.create!(user: user)
    PruneUnconfirmedUsersJob.new.perform
    expect(ConfirmationToken.count).to eq(1)
  end

  it "destroys all stale users and sends reminder emails to users that need one" do
    travel_to Time.current
    user1 = FactoryBot.create(:user, :confirmed) # Will not be deleted
    user2 = FactoryBot.create(:user) # Will not be deleted
    FactoryBot.create(:user, created_at: 31.days.ago) # Will be deleted
    FactoryBot.create(:user, created_at: 30.days.ago) # Will be deleted
    user3 = FactoryBot.create(:user, created_at: 29.days.ago) # Will have a reminder email sent
    token3 = user3.confirmation_tokens.create!
    user4 = FactoryBot.create(:user, created_at: 21.days.ago) # Will have a reminder email sent
    token4 = user4.confirmation_tokens.create!
    user5 = FactoryBot.create(:user, created_at: 21.days.ago, confirmation_reminder_sent_at: DateTime.new(2026, 1, 1, 10)) # Will not have a reminder email sent
    user6 = FactoryBot.create(:user, created_at: 20.days.ago) # Will have a reminder email sent
    token6 = user6.confirmation_tokens.create!
    user7 = FactoryBot.create(:user, created_at: 19.days.ago) # Will not have a reminder email sent

    expect(ConfirmationsMailer).to receive(:reminder).with(user3, token3).and_call_original
    expect(ConfirmationsMailer).to receive(:reminder).with(user4, token4).and_call_original
    expect(ConfirmationsMailer).to receive(:reminder).with(user6, token6).and_call_original
    PruneUnconfirmedUsersJob.new.perform
    expect(User.count).to eq 7
    expect(user1.reload.confirmation_reminder_sent_at).to be_nil
    expect(user2.reload.confirmation_reminder_sent_at).to be_nil
    expect(user3.reload.confirmation_reminder_sent_at).to eq Time.current
    expect(user4.reload.confirmation_reminder_sent_at).to eq Time.current
    expect(user5.reload.confirmation_reminder_sent_at).to eq DateTime.new(2026, 1, 1, 10)
    expect(user6.reload.confirmation_reminder_sent_at).to eq Time.current
    expect(user7.reload.confirmation_reminder_sent_at).to be_nil
  end
end
