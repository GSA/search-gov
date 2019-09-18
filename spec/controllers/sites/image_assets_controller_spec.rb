require 'spec_helper'

describe Sites::ImageAssetsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when site params are not valid' do
        before do
          expect(site).to receive(:css_property_hash).and_return(font_family: 'Arial, san-serif')
          expect(site).to receive(:update_attributes).
              with(hash_including('css_property_hash' => { 'font_family' => 'Arial, san-serif',
                                                           'page_background_image_repeat' => 'repeat-x' })).
              and_return(false)

          put :update,
              params: {
                site_id: site.id,
                id: 100,
                image_asset: {
                  css_property_hash: {
                    page_background_image_repeat: 'repeat-x'
                  }
                }
              }
        end

        it { is_expected.to render_template(:edit) }
      end
    end
  end
end
