require 'spec_helper'

describe Sites::SettingsController do
  fixtures :users, :affiliates
  before { activate_authlogic }

  describe '#edit' do
    it_should_behave_like 'restricted to approved user', :get, :edit

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before { get :edit, site_id: site.id }
    end

    context 'when logged in as super admin' do
      include_context 'super admin logged in to a site'

      before { get :edit, site_id: site.id }
    end
  end

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update

    context 'when approved user successfully update the settings' do
      include_context 'approved user logged in to a site'

      before do
        site.should_receive(:update_attributes).
            with('display_name' => 'new name').
            and_return true

        put :update,
            site_id: site.id,
            site: { display_name: 'new name', not_allowed_key: 'not allowed value' }
      end

      it { should redirect_to edit_site_setting_path(site) }
      it { should set_the_flash.to /Your site settings have been updated/ }
    end

    context 'when approved user successfully update the settings' do
      include_context 'approved user logged in to a site'

      before do
        site.should_receive(:update_attributes).
            with('display_name' => 'new name').
            and_return false

        put :update,
            site_id: site.id,
            site: { display_name: 'new name', not_allowed_key: 'not allowed value' }
      end

      it { should render_template :edit }
    end
  end
end
