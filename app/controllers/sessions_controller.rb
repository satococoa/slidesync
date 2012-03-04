class SessionsController < ApplicationController
  def create
    user = User.find_or_create_by_auth_hash(auth_hash)
    if user.present?
      session[:user_id] = user.id
    end
    if session[:redirect_to].present?
      url = session[:redirect_to]
      session.delete(:redirect_to)
      redirect_to url
    else
      redirect_to :root
    end
  end

  def destroy
    session.clear
    redirect_to :root
  end

  private
  def auth_hash
    request.env['omniauth.auth']
  end
end
