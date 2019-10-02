require 'spec_helper'

describe OmniauthCallbacksController do

  fixtures :users

  describe '#login_dot_gov' do
    before do
      mock_user_auth('12345', 'test@gsa.gov')
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:login_dot_gov]
      get :login_dot_gov
    end

    let(:user) { User.find_by(email: 'test@gsa.gov') }

    it { is_expected.to redirect_to(admin_home_page_path) }

    context 'when the new user info is saved' do
      before do
        get :login_dot_gov
      end

      it 'saves the email' do
        expect(user.email).to(eq 'test@gsa.gov')
      end
      it 'saves the uid' do
        expect(user.uid).to(eq '12345')
      end
    end

    context 'when the existing user with no uid info is saved' do
      before do
        mock_user_auth('12345', 'user_with_out_uid@fixtures.org')
        get :login_dot_gov
      end

      let(:user) { User.find_by(email: 'user_with_out_uid@fixtures.org') }

      it 'saves the email' do
        expect(user.email).to(eq 'user_with_out_uid@fixtures.org')
      end
      it 'saves the uid' do
        expect(user.uid).not_to be_nil
      end
    end

    context 'when the existing user with uid info is saved' do

      before do
        mock_user_auth('11111', 'user_with_uid@fixtures.org')
        get :login_dot_gov
      end

      let(:user) { User.find_by(email: 'user_with_uid@fixtures.org') }

      it 'saves the email' do
        expect(user.email).to(eq 'user_with_uid@fixtures.org')
      end
      it 'saves the uid' do
        expect(user.uid).not_to be_nil
      end
    end
  end
end