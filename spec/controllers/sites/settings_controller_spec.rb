require 'spec_helper'

describe Sites::SettingsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#edit' do
    it_should_behave_like 'restricted to approved user', :get, :edit, site_id: 100

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
    it_should_behave_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when approved user successfully update the settings' do
      include_context 'approved user logged in to a site'

      before do
        expect(site).to receive(:update_attributes).
            with('display_name' => 'new name', 'website' => 'usasearch.howto.gov').
            and_return true

        adapter = double(NutshellAdapter)
        expect(NutshellAdapter).to receive(:new).and_return(adapter)
        expect(adapter).to receive(:push_site).with(site)

        put :update,
            site_id: site.id,
            site: { display_name: 'new name',
                    website: 'usasearch.howto.gov',
                    not_allowed_key: 'not allowed value' }
      end

      it { is_expected.to redirect_to edit_site_setting_path(site) }
      it { is_expected.to set_flash.to /Your site settings have been updated/ }
    end

    context 'when approved user failed to update the settings' do
      include_context 'approved user logged in to a site'

      before do
        expect(site).to receive(:update_attributes).
            with('display_name' => 'new name').
            and_return false

        put :update,
            site_id: site.id,
            site: { display_name: 'new name', not_allowed_key: 'not allowed value' }
      end

      it { is_expected.to render_template :edit }
    end
  end
end
