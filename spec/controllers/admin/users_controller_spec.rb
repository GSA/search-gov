require 'spec_helper'

describe Admin::UsersController do
  fixtures :users

  context 'when not logged in' do
    it 'should redirect to the login page' do
      get :send_email, id: 42
      response.should redirect_to login_path
    end
  end

  context 'when logged in' do
    before do
      activate_authlogic
      UserSession.create(email: user.email, password: 'admin')
    end

    context 'as a non-affiliate-admin user' do
      let(:user) { users('non_affiliate_admin') }

      it 'should redirect to the account page' do
        get :send_email, id: user.id
        response.should redirect_to account_path
      end
    end

    context 'as an affiliate-admin user' do
      let(:user) { users('affiliate_admin') }

      it 'should redirect to the admin_emails page' do
        get :send_email, id: user.id
        response.should redirect_to admin_emails_path(user)
      end
    end
  end
end
