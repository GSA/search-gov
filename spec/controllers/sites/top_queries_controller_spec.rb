require 'spec_helper'

describe Sites::TopQueriesController do
  fixtures :users, :affiliates, :memberships
  let(:site) { affiliates(:basic_affiliate) }

  before { activate_authlogic }

  describe "#new" do
    it_should_behave_like 'restricted to approved user', :get, :new

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when queries exist in the given time frame' do
        let(:top_queries) { [QueryCount.new('foo', 10), QueryCount.new('bar', 9)] }

        before do
          DailyQueryStat.stub(:most_popular_terms).with(site.name, Date.yesterday, Date.current, Sites::TopQueriesController::CSV_RESULTS_SIZE).and_return top_queries
          get :new, site_id: site.id, format: 'csv', start_date: Date.yesterday, end_date: Date.current
        end

        it { should assign_to(:top_query_counts).with(top_queries) }
        it { should render_template(:new) }
      end

      context 'when queries do not exist in the given time frame' do
        let(:top_queries) { DailyQueryStat::INSUFFICIENT_DATA }

        before do
          DailyQueryStat.stub(:most_popular_terms).with(site.name, Date.yesterday, Date.current, Sites::TopQueriesController::CSV_RESULTS_SIZE).and_return top_queries
          get :new, site_id: site.id, format: 'csv', start_date: Date.yesterday, end_date: Date.current
        end

        it { should assign_to(:top_query_counts).with([]) }
        it { should render_template(:new) }
      end
    end
  end
end