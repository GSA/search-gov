require 'spec_helper'

describe Sites::DisplaysController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  let(:site) { affiliates(:basic_affiliate) }

  describe '#update' do
    it_should_behave_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when site params are valid' do
        before do
          allow(controller).to receive(:site).and_return(site)
          allow(site).to receive(:destroy_and_update_attributes).and_return(true)
          allow(site).to receive_message_chain(:connections, :build)
        end

        it 'redirects to the edit page with a success message' do
          put :update, params: { site_id: site.id, site: { default_search_label: 'Search' } }

          expect(response).to redirect_to(edit_site_display_path(site))
          expect(flash[:success]).to match('You have updated your site display settings.')
        end
      end

      context 'when site params are not valid' do
        before do
          allow(controller).to receive(:site).and_return(site)
          allow(site).to receive(:destroy_and_update_attributes).and_return(false)
          allow(site).to receive_message_chain(:connections, :build)
        end

        it 'renders the edit template' do
          put :update, params: { site_id: site.id, site: { default_search_label: 'Search' } }

          expect(response).to render_template(:edit)
        end
      end
    end

    context 'when updating filter settings' do
      include_context 'approved user logged in to a site'

      let(:filter_setting) { FilterSetting.create!(affiliate_id: site.id) }
      let(:filter) do
        filter_setting.filters.create!(
          label: 'Original Label',
          type: 'CustomFilter',
          position: 0,
          enabled: false
        )
      end

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
        allow(controller).to receive(:site).and_return(site)
        allow(site).to receive_messages(filter_setting: filter_setting, destroy_and_update_attributes: true)
        allow(site).to receive_message_chain(:connections, :build)
      end

      it 'updates nested filter attributes correctly' do
        put :update, params: { site_id: site.id, site: filter_params }

        permitted_params = ActionController::Parameters.new(
          filter_setting_attributes: {
            id: filter_setting.id.to_s,
            filters_attributes: {
              '0': {
                id: filter.id.to_s,
                position: '1',
                label: 'Updated Label',
                enabled: 'true'
              }
            }
          }
        ).permit!

        expect(site).to have_received(:destroy_and_update_attributes).with(permitted_params)
      end

      it 'sets the success flash' do
        put :update, params: { site_id: site.id, site: filter_params }

        expect(response).to redirect_to(edit_site_display_path(site))
        expect(flash[:success]).to eq('You have updated your site display settings.')
      end
    end
  end
end
