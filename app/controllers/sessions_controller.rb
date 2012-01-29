class SessionsController < ApplicationController
  def create
    logger.info auth_hash
  end

  def destroy
    session.clear
  end

  private
  def auth_hash
    request.env['omniauth.auth']
  end
end
