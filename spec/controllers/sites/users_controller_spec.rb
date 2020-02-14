require 'spec_helper'

describe Sites::UsersController do
  fixtures :users, :affiliates, :memberships

  before do
    activate_authlogic
  end

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index, site_id: 100

    it_behaves_like 'require complete account', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      let(:site_users) { [mock_model(User)] }
      include_context 'approved user logged in to a site'

      before do
        expect(site).to receive(:users).and_return site_users
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with site }
      it { is_expected.to assign_to(:users).with site_users }
    end
  end

  describe '#new' do
    it_should_behave_like 'restricted to approved user', :get, :new, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before { get :new, params: { site_id: site.id } }

      it { is_expected.to assign_to(:site).with site }
      it { is_expected.to assign_to(:user).with_kind_of(User) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when new user does not exist in the system and user params are valid' do
        let(:new_user) { mock_model(User, email: 'john@email.gov') }

        before do
          expect(User).to receive(:find_by_email).with('john@email.gov').and_return nil
          expect(User).to receive(:new_invited_by_affiliate).
              with(current_user, site, { 'contact_name' => 'John Doe', 'email' =>'john@email.gov' }).
              and_return(new_user)

          expect(new_user).to receive(:save).and_return(true)
          expect(new_user).to receive(:add_to_affiliate).
            with(site, "User #{current_user.id}, affiliate_manager@fixtures.org")

          post :create,
               params: {
                 site_id: site.id,
                 user: { contact_name: 'John Doe',
                         email: 'john@email.gov',
                         not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:user).with(new_user) }
        it { is_expected.to redirect_to site_users_path(site) }
        it { is_expected.to set_flash.to(/notified john@email\.gov on how to login/) }
      end

      context 'when new user does not exist in the system and user params are invalid' do
        let(:new_user) { mock_model(User, email: 'john@email.gov') }

        before do
          expect(User).to receive(:find_by_email).with('john@email.gov').and_return nil
          expect(User).to receive(:new_invited_by_affiliate).
              with(current_user, site, { 'contact_name' => '', 'email' =>'john@email.gov' }).
              and_return(new_user)

          expect(new_user).to receive(:save).and_return(false)
          post :create,
               params: {
                 site_id: site.id,
                 user: { contact_name: '',
                         email: 'john@email.gov',
                         not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:user).with(new_user) }
        it { is_expected.to render_template(:new) }
      end

      context 'when new user exists in the system but does not have access to the site' do
        let(:new_user) { mock_model(User, email: 'john@email.gov') }
        let(:site_users) { double('site users') }

        before do
          expect(User).to receive(:find_by_email).with('john@email.gov').and_return new_user
          expect(new_user).to receive(:send_new_affiliate_user_email).with(site, current_user)
          expect(site).to receive(:users).once.and_return(site_users)
          expect(site_users).to receive(:exists?).and_return(false)
          expect(new_user).to receive(:add_to_affiliate).
            with(site, "User #{current_user.id}, affiliate_manager@fixtures.org")

          post :create,
               params: {
                 site_id: site.id,
                 user: { contact_name: 'John Doe',
                         email: 'john@email.gov' }
               }
        end

        it { is_expected.to assign_to(:user).with(new_user) }
        it { is_expected.to redirect_to site_users_path(site) }
        it { is_expected.to set_flash.to(/You have added john@email\.gov to this site/) }
      end

      context 'when new user already has access to the site' do
        let(:existing_user) { mock_model(User, email: 'john@email.gov') }
        let(:site_users) { double('site users') }
        let(:new_user) { mock_model(User, email: 'john@email.gov') }

        before do
          expect(User).to receive(:find_by_email).with('john@email.gov').and_return existing_user
          expect(site).to receive(:users).and_return(site_users)
          expect(site_users).to receive(:exists?).with(id: existing_user.id).and_return(true)
          expect(User).to receive(:new).
              with({ 'contact_name' => 'John Doe', 'email' => 'john@email.gov' }).
              and_return(new_user)

          post :create,
               params: {
                 site_id: site.id,
                 user: { contact_name: 'John Doe',
                         email: 'john@email.gov' }
               }
        end

        it { is_expected.to assign_to(:user).with(new_user) }
        it { is_expected.to set_flash.now[:notice].to(/john@email\.gov already has access to this site/) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :put, :destroy, id: 100, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:target_user) { mock_model(User, id: 100, email: 'john@email.gov') }

      before do
        expect(User).to receive(:find).with('100').and_return(target_user)
      end

      it 'removes the user from the site' do
        expect(target_user).to receive(:remove_from_affiliate).
          with(site, "User #{current_user.id}, affiliate_manager@fixtures.org")

        put :destroy,
            params: {
              id: 100,
              site_id: site.id
            }
      end
    end
  end
end
