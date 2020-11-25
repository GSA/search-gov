# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  class LoginError < StandardError
  end

  class InternalLoginError < StandardError
  end

  def login_dot_gov
    try_to_login
  rescue LoginError
    flash[:error] = 'Access Denied: These credentials are not recognized as valid' \
                    ' for accessing Search.gov. <br />Please reach out to' \
                    ' search@support.digitalgov.gov if you believe this is an error.'
    redirect_to('/login')
  rescue InternalLoginError => e
    flash[:error] = "login internal error: #{e.message}"
    redirect_to('/login')
  end

  def try_to_login
    @return_to = session[:return_to]
    reset_session
    set_id_token
    set_user_session
    redirect_to(destination)
  end

  def destination_edit_account
    (user.approval_status == 'pending approval' && edit_account_path) ||
      (!user.complete? && edit_account_path)
  end

  def destination_affiliate_admin
    user.is_affiliate_admin? && admin_home_page_path
  end

  def destination_site_page
    user.is_affiliate? && affiliate_site_page
  end

  def destination_original
    @return_to
  end

  def destination
    destination_edit_account ||
      destination_original ||
      destination_affiliate_admin ||
      destination_site_page ||
      new_site_path
  end

  def affiliate_site_page
    if user.default_affiliate
      site_path(user.default_affiliate)
    elsif !user.affiliates.empty?
      site_path(user.affiliates.first)
    end
  end

  def user
    @user ||= User.from_omniauth(omniauth_data)
    raise LoginError unless @user&.login_allowed? || @user&.is_pending_approval?

    @user
  end

  def omniauth_data
    raise InternalLoginError, 'no omniauth data' unless request.env['omniauth.auth']

    request.env['omniauth.auth']
  end

  def credentials
    raise InternalLoginError, 'no user credentials' unless omniauth_data['credentials']

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
