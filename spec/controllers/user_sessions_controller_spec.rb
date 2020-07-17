# frozen_string_literal: true

require 'spec_helper'

describe UserSessionsController do
  fixtures :users

  describe '#security_notification' do
    context 'when a user is not logged in' do
      before { get :security_notification }

      it { is_expected.to render_template(:security_notification) }
    end

    context 'when a user is already logged in' do
      before { activate_authlogic }

      include_context 'approved user logged in'

      before { get :security_notification }

      it { is_expected.to redirect_to(account_path) }
    end
  end

  describe "logging out" do
    let(:login_uri) do
      "#{request.protocol}#{request.host_with_port}/login"
    end

    let(:id_token) { 'fake_id_token' }

    let(:login_dot_gov_logout_uri) do
      base_uri = URI(Rails.application.secrets.login_dot_gov[:idp_base_url])
      URI::HTTPS.build(
        host: base_uri.host,
        path: '/openid_connect/logout',
        query: {
          id_token_hint: id_token,
          post_logout_redirect_uri: login_uri,
          state: '1234567890123456789012'
        }.to_query
      ).to_s
    end


    before { activate_authlogic }
    before { session[:id_token]= id_token }
    include_context 'approved user logged in'
    before { delete :destroy }

    it { is_expected.to redirect_to(login_dot_gov_logout_uri) }

  end
end
