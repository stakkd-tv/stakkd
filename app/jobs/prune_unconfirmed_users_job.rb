class PruneUnconfirmedUsersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ConfirmationToken.stale.destroy_all
    User.stale.destroy_all
    User.includes(:confirmation_tokens).needing_confirmation_reminder.each do |user|
      confirmation_token = user.confirmation_tokens.active.first || user.confirmation_tokens.create
      ConfirmationsMailer.reminder(user, confirmation_token).deliver_later
      user.update(confirmation_reminder_sent_at: Time.current)
    end
  end
end
