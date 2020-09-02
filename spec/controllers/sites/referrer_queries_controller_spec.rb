require 'spec_helper'

describe Sites::ReferrerQueriesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'
      let(:top_n) { [['query1', 10], ['query2', 5]] }
      let(:rtu_top_queries) { double(RtuTopQueries, top_n: top_n) }
      let(:query_args) do
        [
          site.name,
          'search',
          Date.parse('2019-11-01'),
          Date.parse('2019-11-11'),
          'referrer',
          'http://www.url.gov',
          { field: 'params.query.raw', size: 10000 }
        ]
      end
      let(:query) { instance_double(DateRangeTopNFieldQuery, body: '') }

      before do
        travel_to(Time.gm(2019, 11, 11))
        expect(DateRangeTopNFieldQuery).
          to receive(:new).with(*query_args).and_return(query)
        allow(RtuTopQueries).to receive(:new).and_return rtu_top_queries
        get :show,
            params: {
              site_id: site.id,
              start_date: Date.current,
              end_date: Date.current,
              url: 'http://www.url.gov'
            }
      end

      after { travel_back }

      it { is_expected.to assign_to(:top_queries).with(top_n) }
    end
  end

end
