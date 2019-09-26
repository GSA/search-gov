require 'spec_helper'

describe OmniauthCallbacksController do
  before do
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:login_dot_gov]
  end

  describe '#login_dot_gov' do
    subject(:login_dot_gov) { get :login_dot_gov }

    #it 'sets the email and uid' do
    #  expect(session[:email].to(eq(User.last.email)))
    #end
    it { is_expected.to redirect_to(admin_home_page_path) }

  end
end