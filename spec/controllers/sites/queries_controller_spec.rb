require 'spec_helper'

describe Sites::QueriesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }
  let(:rtu_queries_request) { double(RtuQueriesRequest) }

  describe '#new' do
    it_should_behave_like 'restricted to approved user', :get, :new, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        expect(RtuQueriesRequest).to receive(:new).with(
          site: site, filter_bots: current_user.sees_filtered_totals?,
          start_date: Date.current.beginning_of_month, end_date: Date.current
        ).and_return rtu_queries_request
        expect(rtu_queries_request).to receive(:save)
        get :new, site_id: site.id
      end

      it { is_expected.to assign_to(:queries_request).with(rtu_queries_request) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :get, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        params = { "start_date"=>"05/01/2014",
                   "end_date"=>"05/26/2014",
                   "query"=>"foo",
                   "site"=> site,
                   "filter_bots"=> current_user.sees_filtered_totals? }
        expect(RtuQueriesRequest).to receive(:new).with(params).and_return rtu_queries_request
        expect(rtu_queries_request).to receive(:save)
        expect(rtu_queries_request).to receive(:start_date).and_return '05/01/2014'.to_date
        expect(rtu_queries_request).to receive(:end_date).and_return '05/26/2014'.to_date
        post :create, site_id: site.id, rtu_queries_request: { start_date: "05/01/2014", end_date: "05/26/2014", query: "foo" }
      end

      it_should_behave_like 'an analytics controller'
      it { is_expected.to assign_to(:queries_request).with(rtu_queries_request) }
      it { is_expected.to render_template(:new) }
    end
  end
end
