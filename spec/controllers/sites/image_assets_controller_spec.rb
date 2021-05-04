# frozen_string_literal: true

describe Sites::ImageAssetsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when site params are not valid' do
        before do
          put :update,
              params: {
                site_id: site.id,
                id: 100,
                image_asset: {
                  css_property_hash: {
                    logo_alignment: 'invalid'
                  }
                }
              }
        end

        it { is_expected.to render_template(:edit) }
      end
    end
  end
end
