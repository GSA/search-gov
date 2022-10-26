# frozen_string_literal: true

class UserSessionsController < ApplicationController
  before_action :require_user, only: :destroy

  def security_notification
    return unless current_user

    landing_page = LandingPageFinder.new(current_user, params[:return_to]).landing_page
    redirect_to(landing_page)
  end

  def destroy
    id_token = session[:id_token]
    reset_session
    current_user_session.destroy
    redirect_to(LoginDotGovSettings.logout_redirect_uri(id_token, login_uri), allow_other_host: true)
  end

  def login_uri
    "#{request.protocol}#{request.host_with_port}/login"
  end
end
