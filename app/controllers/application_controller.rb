class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_active_storage_current

  private

  def set_active_storage_current
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
  end
end
