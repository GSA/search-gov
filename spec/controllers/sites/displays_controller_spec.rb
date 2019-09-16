require 'spec_helper'

describe Sites::DisplaysController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when site params are valid' do
        before do
          expect(site).to receive(:destroy_and_update_attributes).and_return(true)
          allow(site).to receive_message_chain(:connections, :build)

          put :update,
              params: {
                site_id: site.id,
                id: 100,
                site: { default_search_label: 'Search' }
              }
        end

        it { is_expected.to redirect_to(edit_site_display_path(site)) }

        it 'sets the flash success message' do
          expect(flash[:success]).to match('You have updated your site display settings.')
        end
      end

      context 'when site params are not valid' do
        before do
          expect(site).to receive(:destroy_and_update_attributes).and_return(false)
          allow(site).to receive_message_chain(:connections, :build)

          put :update,
              params: {
                site_id: site.id,
                id: 100,
                site: { default_search_label: 'Search' }
              }
        end

        it { is_expected.to render_template(:edit) }
      end
    end
  end
end
