class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :logged_in?

  private
  def require_login
    unless logged_in?
      session[:redirect_to] = url_for(params)
      redirect_to '/auth/twitter'
    end
  end
  def current_user
    @current_user ||= User.find(session[:user_id]) if logged_in?
  end
  def logged_in?
    session[:user_id].present?
  end
end
