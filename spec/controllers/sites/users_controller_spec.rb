require 'spec_helper'

describe Sites::UsersController do
  fixtures :users, :affiliates, :memberships

  let(:adapter) { mock(NutshellAdapter) }

  before do
    activate_authlogic
    NutshellAdapter.stub(:new) { adapter }
  end

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      let(:site_users) { [mock_model(User)] }
      include_context 'approved user logged in to a site'

      before do
        site.should_receive(:users).and_return site_users
        get :index, site_id: site.id
      end

      it { should assign_to(:site).with site }
      it { should assign_to(:users).with site_users }
    end
  end

  describe '#new' do
    it_should_behave_like 'restricted to approved user', :get, :new

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before { get :new, site_id: site.id }

      it { should assign_to(:site).with site }
      it { should assign_to(:user).with_kind_of(User) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when new user does not exist in the system and user params are valid' do
        let(:new_user) { mock_model(User, email: 'john@email.gov', nutshell_id: 42) }

        before do
          User.should_receive(:find_by_email).with('john@email.gov').and_return nil
          User.should_receive(:new_invited_by_affiliate).
              with(current_user, site, { 'contact_name' => 'John Doe', 'email' =>'john@email.gov' }).
              and_return(new_user)

          new_user.should_receive(:save).and_return(true)
          adapter.should_receive(:push_site).with(site)
          adapter.should_receive(:new_note).with(new_user, '@[Contacts:1001] added @[Contacts:42], john@email.gov to @[Leads:99] NPS Site [nps.gov].')

          post :create,
               site_id: site.id,
               user: { contact_name: 'John Doe',
                       email: 'john@email.gov',
                       not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:user).with(new_user) }
        it { should redirect_to site_users_path(site) }
        it { should set_the_flash.to(/notified john@email\.gov on how to login/) }
      end

      context 'when new user does not exist in the system and user params are invalid' do
        let(:new_user) { mock_model(User, email: 'john@email.gov') }

        before do
          User.should_receive(:find_by_email).with('john@email.gov').and_return nil
          User.should_receive(:new_invited_by_affiliate).
              with(current_user, site, { 'contact_name' => '', 'email' =>'john@email.gov' }).
              and_return(new_user)

          new_user.should_receive(:save).and_return(false)
          post :create,
               site_id: site.id,
               user: { contact_name: '',
                       email: 'john@email.gov',
                       not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:user).with(new_user) }
        it { should render_template(:new) }
      end

      context 'when new user exists in the system but does not have access to the site' do
        let(:new_user) { mock_model(User, email: 'john@email.gov', nutshell_id: 42) }
        let(:site_users) { mock('site users') }

        before do
          User.should_receive(:find_by_email).with('john@email.gov').and_return new_user
          site.should_receive(:users).twice.and_return(site_users)
          site_users.should_receive(:exists?).and_return(false)
          site_users.should_receive(:<<).with(new_user)

          email = mock('email')
          Emailer.should_receive(:new_affiliate_user).with(site, new_user, current_user).
              and_return(email)
          email.should_receive(:deliver)

          adapter.should_receive(:push_site).with(site)
          adapter.should_receive(:new_note).with(new_user, '@[Contacts:1001] added @[Contacts:42], john@email.gov to @[Leads:99] NPS Site [nps.gov].')

          post :create,
               site_id: site.id,
               user: { contact_name: 'John Doe',
                       email: 'john@email.gov' }
        end

        it { should assign_to(:user).with(new_user) }
        it { should redirect_to site_users_path(site) }
        it { should set_the_flash.to(/You have added john@email\.gov to this site/) }
      end

      context 'when new user already has access to the site' do
        let(:existing_user) { mock_model(User, email: 'john@email.gov') }
        let(:site_users) { mock('site users') }
        let(:new_user) { mock_model(User, email: 'john@email.gov') }

        before do
          User.should_receive(:find_by_email).with('john@email.gov').and_return existing_user
          site.should_receive(:users).and_return(site_users)
          site_users.should_receive(:exists?).with(existing_user).and_return(true)
          User.should_receive(:new).
              with({ 'contact_name' => 'John Doe', 'email' => 'john@email.gov' }).
              and_return(new_user)

          post :create,
               site_id: site.id,
               user: { contact_name: 'John Doe',
                       email: 'john@email.gov' }
        end

        it { should assign_to(:user).with(new_user) }
        it { should set_the_flash[:notice].to(/john@email\.gov already has access to this site/).now }
        it { should render_template(:new) }
      end
    end
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :put, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:target_user) { mock_model(User, id: 100, nutshell_id: 42, email: 'john@email.gov') }
      let(:remaining_sites) { [] }

      before do
        User.should_receive(:find).with('100').and_return(target_user)

        memberships = mock('membership')
        Membership.should_receive(:where).with(user_id: 100, affiliate_id: site.id).
          and_return(memberships)
        memberships.should_receive(:destroy_all)
      end

      describe 'site pushing' do
        before { adapter.should_receive(:new_note) }

        it 'pushes to Nutshell' do
          adapter.should_receive(:push_site).with(site)

          put :destroy,
              id: 100,
              site_id: site.id
        end
      end

      describe 'nutshell audit trail' do
        before { adapter.should_receive(:push_site) }

        it 'creates a Nutshell note indicating user removal' do
          expected_message = '@[Contacts:1001] removed @[Contacts:42], john@email.gov from @[Leads:99] NPS Site [nps.gov].'
          adapter.should_receive(:new_note).with(target_user, expected_message)

          put :destroy,
              id: 100,
              site_id: site.id
        end
      end
    end
  end
end
