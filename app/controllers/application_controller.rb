class ApplicationController < ActionController::Base
  protect_from_forgery

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if logged_in?
  end
  def logged_in?
    session[:user_id].present?
  end
  helper_method :current_user, :logged_in?
end
