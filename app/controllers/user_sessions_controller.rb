class UserSessionsController < ApplicationController
  before_action :reset_session, only: [:destroy]
  before_action :require_user, only: :destroy

  def security_notification
    redirect_to(account_path) if current_user && current_user&.complete?
  end

  def destroy
    id_token= session[:id_token]
    login_dot_gov_host= 'https://idp.int.identitysandbox.gov'
    login_dot_gov_logout_endpoint= '/openid_connect/logout'
    login_dot_gov_logout_url= "#{login_dot_gov_host}#{login_dot_gov_logout_endpoint}"

    redirect_uri= URI::HTTPS.build(host: 'idp.int.identitysandbox.gov',
                                   path: '/openid_connect/logout',
                                   query: {
                                     id_token_hint: id_token,
                                     post_logout_redirect_uri: 'http://localhost:3000/login',
                                     state: '1234567890123456789012'
                                   }.to_query).to_s
    reset_session
    current_user_session.destroy
    redirect_to(redirect_uri)
  end
end
