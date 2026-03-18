class ConfirmationsMailer < ApplicationMailer
  def confirm(token)
    @token = token
    @user = token.user
    mail subject: "Confirm your Stakkd account", to: @user.email_address
  end
end
