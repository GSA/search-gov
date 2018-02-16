require 'spec_helper'

describe Sites::TemplatedFontAndColorsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#edit' do
  end

  describe '#update' do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    let(:template) { affiliate_templates(:usagov_classic) }
    it_should_behave_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create current_user
        expect(User).to receive(:find_by_id).and_return(current_user)
      end

      it "resets the template if the checkbox is selected" do
        put :update,
            site_id: affiliate.id,
            reset_theme: true,
            schema: { css_property_hash: { font_family: 'Arial, san-serif' } }

            expect(response).to redirect_to  :edit_site_templated_font_and_colors
      end

      it "should reset the template if the checkbox is selected" do
        put :update,
            site_id: affiliate.id,
            reset_theme: true,
            schema: { css_property_hash: { font_family: 'Arial, san-serif' } }

            expect(response).to redirect_to  :edit_site_templated_font_and_colors
      end
    end
  end
end
