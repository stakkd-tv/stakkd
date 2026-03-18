# Preview all emails at http://localhost:3000/rails/mailers/confirmations_mailer
class ConfirmationsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/confirmations_mailer/confirm
  def confirm
    token = ConfirmationToken.new(user: User.first, token: "1234", expires_at: 15.minutes.from_now)
    ConfirmationsMailer.confirm(token)
  end
end
