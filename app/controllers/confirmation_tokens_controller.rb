class ConfirmationTokensController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])
    if user && !user.confirmed?
      token = user.confirmation_tokens.active.first || user.confirmation_tokens.create
      ConfirmationsMailer.confirm(token).deliver_later
    end

    redirect_to new_session_path, notice: "A confirmation email has been resent to your email (if a user was found with that email address)."
  end
end
