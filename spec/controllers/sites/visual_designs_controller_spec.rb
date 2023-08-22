# frozen_string_literal: true

describe Sites::VisualDesignsController do
  before { activate_authlogic }

  describe '#edit' do
    it_behaves_like 'restricted to approved user', :get, :edit, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before { get :edit, params: { site_id: site.id } }

      it { is_expected.to assign_to(:site).with(site) }
    end
  end

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when site params are valid' do
        before do
          put :update,
              params: {
                site_id: site.id,
                site: {
                  visual_design_json: {
                    header_links_font_family: 'georgia',
                    footer_and_results_font_family: 'tahoma'
                  }.merge(Affiliate::DEFAULT_COLORS)
                }
              }
        end

        it { is_expected.to redirect_to(edit_site_visual_design_path(site)) }

        it 'sets the flash success message' do
          expect(flash[:success]).to match('You have updated your font & colors.')
        end
      end

      context 'when logged in as affiliate' do
        include_context 'approved user logged in to a site'

        context 'when site params are not valid' do
          before do
            put :update,
                params: {
                  site_id: site.id,
                  site: {
                    visual_design_json: {
                      header_links_font_family: 'comic sans',
                      footer_and_results_font_family: 'invalid'
                    }.merge(Affiliate::DEFAULT_COLORS)
                  }
                }
          end

          it { is_expected.to render_template(:edit) }
        end
      end
    end
  end
end
