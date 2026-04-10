class UsersController < ApplicationController
  before_action :require_authentication, only: [:settings, :update]
  before_action :set_user, only: [:show, :update]
  before_action :authorize_user, only: [:update]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  TRIVIA = [
    {name: "harry-potter", question: "Who is the main character in Harry Potter?", answers: ["harry potter", "harry", "potter"]},
    {name: "toy-story", question: "What is the name of the toy cowboy in Toy Story?", answers: ["woody"]},
    {name: "pineapple", question: "Who lives in a pineapple under the sea?", answers: ["spongebob", "sponge bob", "spongebob squarepants"]},
    {name: "hulk", question: "What color is the Hulk?", answers: ["green"]}
  ]

  def show
    if @user.private? && current_user != @user
      redirect_to root_path, alert: "You are not authorized to view this profile."
    end
  end

  def new
    @trivia = TRIVIA.sample
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @trivia = trivia_question_from_params || TRIVIA.sample
    unless trivia_valid?
      flash[:alert] = "Bot accounts are not allowed."
      render :new, status: 422
      return
    end

    if @user.save
      token = @user.confirmation_tokens.create
      ConfirmationsMailer.confirm(token).deliver_later
      redirect_to root_path, notice: "Success! You'll need to confirm your email before logging in."
    else
      render :new, status: 422
    end
  end

  def settings
    @user = current_user
  end

  def update
    # NOTE: At the moment, there are no fields that would trigger an
    # error on the user. Come back to this if there are fields in the
    # future that would.
    @user.update(user_update_params)
    redirect_to user_settings_path, notice: "Settings updated successfully."
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

  def set_user
    @user = if params[:id] == "me"
      current_user if authenticated?
    else
      User.from_username(params[:id])
    end
    head :not_found unless @user
  end

  def user_params
    params.expect(user: [:username, :email_address, :password, :password_confirmation])
  end

  def user_update_params
    params.expect(user: [:profile_picture, :background, :biography, :private])
  end

  def trivia_valid?
    trivia = trivia_question_from_params
    return false unless trivia
    trivia[:answers].include?(params[:trivia_answer].downcase)
  end

  def trivia_question_from_params
    TRIVIA.find { it[:name] == params[:trivia_question_name] }
  end

  def authorize_user
    redirect_back fallback_location: root_path, alert: "You are not authorized to perform this action." unless @user == current_user
  end
end
