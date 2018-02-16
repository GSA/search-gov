require 'spec_helper'

describe Admin::UsersController do
  fixtures :users

  context 'when not logged in' do
    it 'should redirect to the login page' do
      get :send_email, id: 42
      expect(response).to redirect_to login_path
    end
  end

  context 'when logged in' do
    before do
      activate_authlogic
      UserSession.create(user)
    end

    context 'as a non-affiliate-admin user' do
      let(:user) { users('non_affiliate_admin') }

      it 'should redirect to the account page' do
        get :send_email, id: user.id
        expect(response).to redirect_to account_path
      end
    end

    context 'as an affiliate-admin user' do
      let(:user) { users('affiliate_admin') }

      it 'should redirect to the admin_emails page' do
        get :send_email, id: user.id
        expect(response).to redirect_to admin_emails_path(user)
      end
    end
  end
end
