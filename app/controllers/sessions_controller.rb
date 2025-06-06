class SessionsController < ApplicationController
  before_action :require_authentication, only: [:destroy]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password)))
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Successfully logged in. Enjoy your stay!"
    else
      @error = "Sorry, but we couldn't find that account. Click the forgot password link if you've forgotten your password or get in touch if you think this is incorrect."
      render :new, status: 422
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: "Successfully logged out. Come back soon!"
  end
end
