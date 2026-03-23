class UsersController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      token = @user.confirmation_tokens.create
      ConfirmationsMailer.confirm(token).deliver_later
      redirect_to root_path, notice: "Success! You'll need to confirm your email before logging in."
    else
      render :new, status: 422
    end
  end

  def confirm
    terminate_session if authenticated?

    token = ConfirmationToken.active.find_by(token: params[:token])
    if token && !token.user.confirmed?
      user = token.user
      user.update(confirmed_at: Time.current)
      token.destroy
      redirect_to new_session_path, notice: "Successfully confirmed your account, you can now login!"
    else
      redirect_to new_confirmation_token_path, alert: "Confirmation link is invalid or has expired. Please request a new confirmation email."
    end
  end

  private

  def user_params
    params.expect(user: [:username, :email_address, :password, :password_confirmation])
  end
end
