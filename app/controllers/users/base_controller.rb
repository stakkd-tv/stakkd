module Users
  class BaseController < ApplicationController
    before_action :set_user
    before_action :check_user_privacy

    private

    def set_user
      @user = if params[:user_id] == "me"
        current_user if authenticated?
      else
        User.from_username(params[:user_id])
      end
      not_found unless @user
    end

    def check_user_privacy
      if current_user != @user && @user.private?
        redirect_to user_path(@user)
      end
    end
  end
end
