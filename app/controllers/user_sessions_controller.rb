# frozen_string_literal: true

class UserSessionsController < ApplicationController
  before_action :require_user, only: :destroy

  def security_notification
    redirect_to(account_path) if current_user && current_user&.complete?
  end

  def destroy
    id_token = session[:id_token]
    reset_session
    current_user_session.destroy
    redirect_to(LoginDotGovSettings.logout_redirect_uri(id_token, login_uri))
  end

  def login_uri
    "#{request.protocol}#{request.host_with_port}/login"
  end
end
