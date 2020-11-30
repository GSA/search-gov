require 'spec_helper'

describe OmniauthCallbacksController do
  describe 'The landing page for GET login_dot_gov' do
    # Bypass Authlogic's cleverness, which only gets in the way for
    # this group of tests.
    before do
      fake_authlogic_session= spy('fake_authlogic_session')
      allow(UserSession).to receive(:create).and_return(fake_authlogic_session)
    end

    # work around infelicitous path naming
    let(:security_warning_path) { login_path }

    let(:omniauth_data) { mock_user_auth }

    let(:rails_session) { {} }

    let(:first_domain)  { Affiliate.new(id: 2, website: 'https://first-domain.gov') }
    let(:second_domain) { Affiliate.new(id: 1, website: 'https://second-domain.gov') }

    let(:user_is_complete) { true }
    let(:user_is_persisted) { true }
    let(:user_is_super_admin) { false }
    let(:user_approval_status) { 'approved' }
    let(:user_domains) { [] }
    let(:user_default_domain) { nil }
    let(:user) do
      new_user= User.new(email: 'user@test.gov',
                         approval_status: user_approval_status,
                         default_affiliate: user_default_domain,
                         is_affiliate_admin: user_is_super_admin)
      allow(new_user).to receive(:affiliates).and_return(user_domains)
      new_user
    end

    before do
      allow(user).to receive(:complete?).and_return(user_is_complete)
      allow(user).to receive(:persisted?).and_return(user_is_persisted)
      subject.instance_variable_set(:@user, user)
    end

    let(:get_login_dot_gov) do
      request.env['omniauth.auth'] = omniauth_data
      get :login_dot_gov, session: rails_session
    end

    describe 'when the user logged in without an explicit destination' do
      describe 'and omniauth failed to authenticate them' do
        let(:omniauth_data) { nil }

        it 'is the security warning page' do
          expect(get_login_dot_gov).to redirect_to(security_warning_path)
        end
      end

      describe 'and the user cannot be persisted' do
        let(:user_is_persisted) { false }

        it 'is the security warning page' do
          expect(get_login_dot_gov).to redirect_to(security_warning_path)
        end
      end

      describe 'and the user is not approved' do
        let(:user_approval_status) { 'not_approved' }

        it 'is the security warning page' do
          expect(get_login_dot_gov).to redirect_to(security_warning_path)
        end
      end

      describe 'and the user is pending approval' do
        let(:user_approval_status) { 'pending_approval' }

        it 'is the users account page' do
          expect(get_login_dot_gov).to redirect_to(edit_account_path)
        end
      end

      describe 'and the user is not complete' do
        let(:user_is_complete) { false }

        it 'is the users account page' do
          expect(get_login_dot_gov).to redirect_to(edit_account_path)
        end
      end

      describe 'and the user is not associated with any domains' do
        it 'is the new site page' do
          expect(get_login_dot_gov).to redirect_to(new_site_path)
        end
      end

      describe 'and the user is a member of at least one domain' do
        let(:user_domains) { [first_domain, second_domain] }

        it 'is the first domain the user is a member of' do
          expect(get_login_dot_gov).to redirect_to(site_path(first_domain))
        end
      end

      describe 'and the user has a default domain' do
        let(:user_domains) { [first_domain, second_domain] }
        let(:user_default_domain) { second_domain }

        it 'is the default domain' do
          expect(get_login_dot_gov).to redirect_to(site_path(user_default_domain))
        end
      end

      describe 'and the user is a super admin' do
        let(:user_is_super_admin) { true }
        it 'is the admin page' do
          expect(get_login_dot_gov).to redirect_to(admin_home_page_path)
        end
      end
    end

    describe 'when the user logged in with an explicit destination' do
      let(:explicit_destination) { '/explicit_destination' }
      let(:rails_session) { { return_to: explicit_destination } }

      describe 'and omniauth failed to authenticate them' do
        let(:omniauth_data) { nil }

        it 'is the security warning page' do
          expect(get_login_dot_gov).to redirect_to(security_warning_path)
        end
      end

      describe 'and the user cannot be persisted' do
        let(:user_is_persisted) { false }

        it 'is the security warning page' do
          expect(get_login_dot_gov).to redirect_to(security_warning_path)
        end
      end

      describe 'and the user is not approved' do
        let(:user_approval_status) { 'not_approved' }

        it 'is the security warning page' do
          expect(get_login_dot_gov).to redirect_to(security_warning_path)
        end
      end

      describe 'and the user is pending approval' do
        let(:user_approval_status) { 'pending_approval' }

        it 'is the users account page' do
          expect(get_login_dot_gov).to redirect_to(edit_account_path)
        end
      end

      describe 'and the user is not complete' do
        let(:user_is_complete) { false }

        it 'is the users account page' do
          expect(get_login_dot_gov).to redirect_to(edit_account_path)
        end
      end

      describe 'and the user is not associated with any domains' do
        it 'is the explicit destination' do
          expect(get_login_dot_gov).to redirect_to(explicit_destination)
        end
      end

      describe 'and the user is a member of at least one domain' do
        let(:user_domains) { [first_domain, second_domain] }

        it 'is the explicit destination' do
          expect(get_login_dot_gov).to redirect_to(explicit_destination)
        end
      end

      describe 'and the user has a default domain' do
        let(:user_domains) { [first_domain, second_domain] }
        let(:user_default_domain) { second_domain }

        it 'is the explicit destination' do
          expect(get_login_dot_gov).to redirect_to(explicit_destination)
        end
      end

      describe 'and the user is a super admin' do
        let(:user_is_super_admin) { true }

        it 'is the explicit destination' do
          expect(get_login_dot_gov).to redirect_to(explicit_destination )
        end
      end
    end
  end
end

describe OmniauthCallbacksController do
  describe 'GET login_dot_gov' do
    let(:user) { users(:omniauth_user) }
    let(:auth) { mock_user_auth }

    let(:get_login_dot_gov) do
      request.env['omniauth.auth'] = auth
      get :login_dot_gov
    end

    it 'calls reset_session' do
      expect_any_instance_of(ActionController::Metal).to receive(:reset_session)
      get_login_dot_gov
    end

    context 'when the login is successful' do
      before { get_login_dot_gov }

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

      it 'redirects to access-denied page' do
        expect(get_login_dot_gov).to redirect_to('http://test.host/login')
      end
    end

    context 'when a user is not approved' do
      let(:user) { users(:affiliate_manager_with_not_approved_status) }
      let(:auth) { mock_user_auth(user.email, 'notapproved12345') }

      it 'redirects to access-denied page' do
        expect(get_login_dot_gov).to redirect_to('http://test.host/login')
      end
    end
  end
end
