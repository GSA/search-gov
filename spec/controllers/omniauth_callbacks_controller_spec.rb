require 'spec_helper'

describe OmniauthCallbacksController do
  describe 'GET login_dot_gov' do
    let(:user) { users(:omniauth_user) }
    let(:auth) { mock_user_auth }

    let(:get_login_dot_gov) do
      request.env['omniauth.auth'] = auth
      get :login_dot_gov
    end

    context 'when the login is successful' do
      before { get_login_dot_gov }

      it { is_expected.to redirect_to(admin_home_page_path) }
      it { is_expected.to assign_to(:user).with(user) }
    end

    it 'creates a user session' do
      expect(UserSession).to receive(:create).with(user).and_call_original
      get_login_dot_gov
    end

    context 'securing the session' do
      let(:session) { instance_double(UserSession) }
      let(:secure_cookies) { Rails.application.config.ssl_options[:secure_cookies] }

      before do
        allow(UserSession).to receive(:create).with(user).and_return(session)
      end

      it 'sets the session security' do
        expect(session).to receive(:secure=).with(secure_cookies)
        get_login_dot_gov
      end
    end

    context 'when the user is new' do
      let(:email) { 'brandnewuser@gsa.gov' }
      let(:uid) { 'newuid123' }
      let(:auth) { mock_user_auth(email, uid) }

      it 'creates a new user' do
        expect { get_login_dot_gov }.to change { User.count }.by(1)
      end

      it 'creates a user with the email and UID from omniauth' do
        get_login_dot_gov
        user = User.last
        expect(user.email).to eq 'brandnewuser@gsa.gov'
        expect(user.uid).to eq 'newuid123'
      end
    end

    context 'when an existing user with no uid info is saved' do
      let(:user) { users(:user_without_uid) }
      let(:auth) { mock_user_auth(user.email, 'newuid123') }

      it 'updates the user record with the UID' do
        expect { get_login_dot_gov }.to change{ user.reload.uid }.
          from(nil).to('newuid123')
      end
    end

    context 'when the user record cannot be persisted to the database' do
      before do
        allow_any_instance_of(User).to receive(:persisted?).and_return(false)
      end

      it 'raises an error' do
        expect { get_login_dot_gov }.to raise_error(ActionController::UnknownFormat)
      end
    end
  end
end