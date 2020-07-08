# frozen_string_literal: true

class UserSessionsController < ApplicationController
  before_action :require_user, only: :destroy

  def security_notification
    redirect_to(account_path) if current_user && current_user&.complete?
  end

  def destroy
    id_token= session[:id_token]
    reset_session
    current_user_session.destroy
    redirect_to(logout_redirect_uri(id_token))
  end

  def login_uri
    "#{request.protocol}#{request.host_with_port}/login"
  end

  def logout_redirect_uri(id_token)
    base_uri= URI(Rails.application.secrets.login_dot_gov[:idp_base_url])
    redirect_uri= URI::HTTPS.build(
      host: base_uri.host,
      path: '/openid_connect/logout',
      query: {
        id_token_hint: id_token,
        post_logout_redirect_uri: login_uri,
        state: '1234567890123456789012'
      }.to_query).to_s
  end
end
