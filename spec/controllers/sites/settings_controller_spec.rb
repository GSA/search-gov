require 'spec_helper'

describe Sites::SettingsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#edit' do
    it_behaves_like 'restricted to approved user', :get, :edit, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before { get :edit, params: { site_id: site.id } }
    end

    context 'when logged in as super admin' do
      include_context 'super admin logged in to a site'

      before { get :edit, params: { site_id: site.id } }
    end
  end

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when approved user successfully update the settings' do
      include_context 'approved user logged in to a site'

      before do
        expect(site).to receive(:update).
          with({ 'display_name' => 'new name', 'website' => 'search.gov' }).
          and_return true

        put :update,
            params: {
              site_id: site.id,
              site: { display_name: 'new name',
                      website: 'search.gov',
                      not_allowed_key: 'not allowed value' }
            }
      end

      it { is_expected.to redirect_to edit_site_setting_path(site) }
      it { is_expected.to set_flash.to(/Your site settings have been updated/) }
    end

    context 'when approved user failed to update the settings' do
      include_context 'approved user logged in to a site'

      before do
        expect(site).to receive(:update).
          with({ 'display_name' => 'new name' }).
          and_return false

        put :update,
            params: {
              site_id: site.id,
              site: { display_name: 'new name', not_allowed_key: 'not allowed value' }
            }
      end

      it { is_expected.to render_template :edit }
    end
  end
end
