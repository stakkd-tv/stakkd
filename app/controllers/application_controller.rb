class ApplicationController < ActionController::Base
  include Authentication

  unless Rails.application.config.consider_all_requests_local
    # 500
    rescue_from StandardError, with: :server_error

    # 404
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::RoutingError, with: :not_found
    rescue_from AbstractController::ActionNotFound, with: :not_found
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_active_storage_current

  private

  def not_found
    render "application/not_found", formats: [:html], status: 404
  end

  def server_error(error)
    @error = error
    render "application/server_error", formats: [:html], status: 500
  end

  def set_active_storage_current
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
  end
end
