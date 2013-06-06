class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  def current_user
    @current_user ||= User.find(session[:uid]) if session[:uid]
  end
  helper_method :current_user
end
