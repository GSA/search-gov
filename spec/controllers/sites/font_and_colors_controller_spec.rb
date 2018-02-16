require 'spec_helper'

describe Sites::FontAndColorsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when site params are not valid' do
        before do
          expect(site).to receive(:css_property_hash).and_return(page_background_image_repeat: 'repeat-x')
          expect(site).to receive(:update_attributes).
              with(hash_including('css_property_hash' => { 'font_family' => 'Arial, san-serif',
                                                           'page_background_image_repeat' => 'repeat-x' })).
              and_return(false)

          put :update,
              site_id: site.id,
              site: { css_property_hash: { font_family: 'Arial, san-serif' } }
        end

        it { is_expected.to render_template(:edit) }
      end
    end
  end
end
