require 'spec_helper'

describe OmniauthCallbacksController do

  describe '#login_dot_gov' do
    let(:user) { users(:omniauth_user) }
    let(:auth) { mock_user_auth }

    let(:get_login_dot_gov) do
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
      it { is_expected.to assign_to(:user).with(user) }
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
        #alternative:
        #user = User.find_by(email: 'brandnewuser@gsa.gov')
        user = User.last
        expect(user.email).to eq 'brandnewuser@gsa.gov'
        expect(user.uid).to eq 'newuid123'
      end
    end

    context 'when an existing user with no uid info is saved' do
      let(:user) { users(:user_without_uid) }
      let(:auth) { mock_user_auth(user.email, user.uid) }

      it 'updates the user record with the UID' do

      end
    end


=begin


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
