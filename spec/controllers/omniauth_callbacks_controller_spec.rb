require 'spec_helper'

describe OmniauthCallbacksController do

  describe '#login_dot_gov' do
    let(:user) { users(:omniauth_user) }
    let(:auth) { mock_user_auth }

    subject(:get_login_dot_gov) do
      request.env['omniauth.auth'] = auth
      get :login_dot_gov
    end

    #before do
    #  request.env['omniauth.auth'] = auth
    #  get :login_dot_gov
    #end
    context 'when the login is successful' do
      before { get_login_dot_gov }

      it { is_expected.to redirect_to(admin_home_page_path) }
    end
=begin

    context 'when the new user info is saved' do
      it 'saves the email' do
        expect(user.email).to(eq 'test@gsa.gov')
      end

      it 'saves the uid' do
        expect(user.uid).to(eq '12345')
      end
    end

    context 'when the existing user with no uid info is saved' do
      let(:auth) { mock_user_auth('user_without_uid@fixtures.org', '22222') }
      let(:user) { users(:user_without_uid) }

      it 'saves the uid' do
        expect(user.uid).to eq '22222'
      end
    end

    context 'when the existing user with uid info is saved' do
      let(:auth) { mock_user_auth('user_with_uid@fixtures.org', '11111') }
      let(:user) { users(:user_with_uid) }

      it 'saves the uid' do
        expect(user.uid).to eq '11111'
      end
    end
  end

  context 'when the user record cannot be persisted to the database' do
    before do
      allow(user).to receive(:persisted?).and_return(:false)
    end

    let(:user) { users(:user_with_uid) }

    it { is_expected.not_to redirect_to(admin_home_page_path) }
  end
=end
  end
end
