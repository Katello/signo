class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_gettext_locale

  def is_logged_in?
    current_username.present?
  end

  def current_username
    session[:username]
  end

  def is_authorized(relay_party)
    domain = URI.parse(relay_party).host
    ::Configuration.config.whitelist.map(&:downcase).include?(domain.downcase)
  end
end
