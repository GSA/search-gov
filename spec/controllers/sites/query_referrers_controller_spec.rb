require 'spec_helper'

describe Sites::QueryReferrersController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'
      let(:top_n) { [['url1', 10], ['url2', 5]] }
      let(:rtu_top_queries) { double(RtuTopQueries, top_n: top_n) }

      before do
        allow(RtuTopQueries).to receive(:new).and_return rtu_top_queries
        get :show,
            params: {
              site_id: site.id,
              start_date: Date.current,
              end_date: Date.current,
              query: 'foo'
            }
      end

      it { is_expected.to assign_to(:top_urls).with(top_n) }
    end
  end

end
