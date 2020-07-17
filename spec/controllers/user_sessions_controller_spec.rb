# frozen_string_literal: true

describe UserSessionsController do
  before { activate_authlogic }

  describe '#security_notification' do
    context 'when a user is not logged in' do
      before { get :security_notification }

      it { is_expected.to render_template(:security_notification) }
    end

    context 'when a user is already logged in' do
      include_context 'approved user logged in'

      before { get :security_notification }

      let(:expected_site_path) { site_path(id: current_user.affiliates.first.id) }

      it { is_expected.to redirect_to(expected_site_path) }
    end

    context 'when a not_approved user is logged in' do
      include_context 'not_approved user logged in'

      render_views

      before { get :security_notification }

      it 'shows the access denied text' do
        expect(response.body).to have_content(LandingPageFinder::ACCESS_DENIED_TEXT)
      end
    end
  end

  describe '#destroy' do
    subject(:destroy) { delete :destroy }

    let(:login_uri) do
      "#{request.protocol}#{request.host_with_port}/login"
    end
    let(:id_token) { 'fake_id_token' }
    let(:expected_login_dot_gov_logout_uri) do
      URI::HTTPS.build(
        host: 'idp.int.identitysandbox.gov',
        path: '/openid_connect/logout',
        query: {
          id_token_hint: id_token,
          post_logout_redirect_uri: login_uri,
          state: '1234567890123456789012'
        }.to_query
      ).to_s
    end

    include_context 'approved user logged in'

    before { session[:id_token] = id_token }

    it { is_expected.to redirect_to(expected_login_dot_gov_logout_uri) }
  end
end
