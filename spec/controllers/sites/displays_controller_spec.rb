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

    context 'when updating filter settings' do
      let(:filter_setting) { site.filter_setting }
      let(:filter) { filter_setting.filters.first }

      let(:filter_params) do
        {
          filter_setting_attributes: {
            id: filter_setting.id,
            filters_attributes: {
              '0': {
                id: filter.id,
                position: 1,
                label: 'Updated Label',
                enabled: true
              }
            }
          }
        }
      end

      before do
        allow(site).to receive(:destroy_and_update_attributes).and_return(true)
        allow(site).to receive_message_chain(:connections, :build)

        put :update,
            params: {
              site_id: site.id,
              id: 100,
              site: filter_params
            }
      end

      it 'updates nested filter attributes correctly' do
        expect(site).to have_received(:destroy_and_update_attributes).with(
          ActionController::Parameters.new(filter_params).permit!
        )
      end

      it { is_expected.to redirect_to(edit_site_display_path(site)) }

      it 'sets flash success message' do
        expect(flash[:success]).to match('You have updated your site display settings.')
      end
    end
  end
end
