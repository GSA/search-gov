# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  class OmniauthError < StandardError
  end

  def login_dot_gov
    try_to_login
  rescue OmniauthError => e
    flash[:error] = e.message
    redirect_to('/login')
  end

  private

  def try_to_login
    @return_to = session[:return_to]
    reset_session
    set_id_token
    set_user_session
    redirect_to(destination)
  end

  def destination
    LandingPageFinder.new(user, @return_to).landing_page
  rescue LandingPageFinder::Error => e
    raise OmniauthError, e.message
  end

  def user
    return @user if @user

    @user = User.from_omniauth(omniauth_data)
    raise OmniauthError, 'db error creating user' unless @user.persisted?
    @user
  end

  def omniauth_data
    raise OmniauthError, 'no omniauth data' unless request.env['omniauth.auth']

    request.env['omniauth.auth']
  end

  def credentials
    raise OmniauthError, 'no user credentials' unless omniauth_data['credentials']

    omniauth_data['credentials']
  end

  def set_id_token
    session[:id_token] = credentials['id_token']
  end

  def set_user_session
    user_session = UserSession.create(user)
    user_session.secure = Rails.application.config.ssl_options[:secure_cookies]
  end
end
