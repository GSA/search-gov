# frozen_string_literal: true

describe Sites::FontAndColorsController do
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
                site: { css_property_hash: { font_family: 'Comic Sans' } }
              }
        end

        it { is_expected.to render_template(:edit) }
      end
    end
  end
end
