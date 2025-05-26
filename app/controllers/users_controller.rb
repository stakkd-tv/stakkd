class UsersController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    # TODO: User confirmation
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, notice: "Success! You'll need to confirm your email before logging in."
    else
      render :new, status: 422
    end
  end

  def user_params
    params.expect(user: [:username, :email_address, :password, :password_confirmation])
  end
end
