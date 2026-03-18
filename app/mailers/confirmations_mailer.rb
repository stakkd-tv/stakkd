class ConfirmationsMailer < ApplicationMailer
  def confirm(token)
    @token = token
    @user = token.user
    mail subject: "Confirm your Stakkd account", to: @user.email_address
  end

  def reminder(user, token)
    @token = token
    @user = user
    mail subject: "Your Stakkd account is scheduled for deletion", to: @user.email_address
  end
end
