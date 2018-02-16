require 'spec_helper'

describe Sites::ClicksController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }
  let(:rtu_clicks_request) { double(RtuClicksRequest) }

  describe '#new' do
    it_should_behave_like 'restricted to approved user', :get, :new, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        expect(RtuClicksRequest).to receive(:new).with(
          site: site, filter_bots: current_user.sees_filtered_totals?,
          start_date: Date.current.beginning_of_month, end_date: Date.current
        ).and_return rtu_clicks_request
        expect(rtu_clicks_request).to receive(:save)
        get :new, site_id: site.id
      end

      it { is_expected.to assign_to(:clicks_request).with(rtu_clicks_request) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :get, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'
      it_should_behave_like 'an analytics controller'

      before do
        params = { "start_date"=>"05/01/2014", "end_date"=>"05/26/2014", "site"=> site, "filter_bots"=> current_user.sees_filtered_totals?}
        expect(RtuClicksRequest).to receive(:new).with(params).and_return rtu_clicks_request
        expect(rtu_clicks_request).to receive(:save)
        expect(rtu_clicks_request).to receive(:start_date).and_return "05/01/2014".to_date
        expect(rtu_clicks_request).to receive(:end_date).and_return "05/26/2014".to_date
        post :create, site_id: site.id, rtu_clicks_request: { start_date: "05/01/2014", end_date: "05/26/2014" }
      end

      it { is_expected.to assign_to(:clicks_request).with(rtu_clicks_request) }
      it { is_expected.to render_template(:new) }
    end
  end
end
