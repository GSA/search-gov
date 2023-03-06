require 'spec_helper'

describe Sites::AlertsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#edit' do
    it_behaves_like 'restricted to approved user', :get, :edit, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:alert) { mock_model(Alert) }

      before do
        expect(site).to receive(:alert).and_return(alert)
        get :edit, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:alert).with(alert) }
    end
  end

  describe '#update' do
    it_behaves_like 'restricted to approved user', :put, :update, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when Alert params are valid' do
        let(:alert) { mock_model(Alert) }

        before do
          expect(site).to receive(:alert).and_return(alert)
          expect(alert).to receive(:update).
            with({ 'title' => 'Updated Title for Alert',
                   'text' => 'Some text for the alert.',
                   'status' => 'Active' }).
            and_return(true)

          put :update,
              params: {
                site_id: site.id,
                alert: { title: 'Updated Title for Alert',
                         text: 'Some text for the alert.',
                         status: 'Active',
                         not_allowed_key: 'not allowed value' }
              }
        end

        it { is_expected.to assign_to(:alert).with(alert) }
        it { is_expected.to redirect_to edit_site_alert_path(site) }
        it { is_expected.to set_flash.to('The alert for this site has been updated.') }
      end

      context 'when Alert params are not valid' do
        let(:alert) { mock_model(Alert) }

        before do
          allow(site).to receive(:alert).and_return(alert)
          expect(alert).to receive(:update).
            with({ 'title' => 'Title',
                   'text' => '',
                   'status' => 'Active' }).
            and_return(false)

          put :update,
              params: {
                site_id: site.id,
                alert: { title: 'Title',
                         text: '',
                         status: 'Active' }
              }
        end

        it { is_expected.to assign_to(:alert).with(alert) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end
end
