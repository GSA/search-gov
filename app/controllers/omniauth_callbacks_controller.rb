# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  class LoginError < StandardError
  end

  def login_dot_gov
    reset_session
    set_id_token
    set_user_session
    redirect_to(admin_home_page_path)
  rescue LoginError => e
    flash[:error] = "login internal error: #{e.message}"
    redirect_to('/login')
  end

  def user
    @user ||= User.from_omniauth(omniauth_data)

    raise LoginError, "can't find user #{omniauth_data.info.email}" unless @user

    raise LoginError, "login not allowed for #{@user.email}" unless @user.login_allowed?

    @user
  end

  def omniauth_data
    puts "env auth: #{request.env['omniauth.auth']}".purple
    raise LoginError, 'no omniauth data' unless request.env['omniauth.auth']

    request.env['omniauth.auth']
    #OmniAuth.config.mock_auth[:login_dot_gov] works, but...
  end

  def credentials
    raise LoginError, 'no user credentials' unless omniauth_data['credentials']

    omniauth_data['credentials']
  end

  def set_id_token
    session[:id_token] = credentials['id_token']
  end

  def set_user_session
    puts "setting user session for user:#{user}".cyan
    user_session = UserSession.create(user)
    user_session.secure = Rails.application.config.ssl_options[:secure_cookies]
  end
end
