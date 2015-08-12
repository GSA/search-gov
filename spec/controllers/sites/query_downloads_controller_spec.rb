require 'spec_helper'

describe Sites::QueryDownloadsController do
  render_views
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show

    context 'when affiliate is downloading CSV data' do
      include_context 'approved user logged in to a site'
      let(:top_queries_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_queries.json")) }
      let(:top_human_queries_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_human_queries.json")) }
      let(:top_clicks_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_clicks.json")) }
      let(:top_human_clicks_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_human_clicks.json")) }

      before do
        ES::client_reader.stub(:search).and_return(top_queries_response, top_human_queries_response, top_clicks_response, top_human_clicks_response)
      end

      it 'should generate a CSV of human and bot traffic for some date range, sorted by human count' do
        get :show, start_date: '2014-06-08', end_date: '2014-06-14', format: 'csv'
        response.content_type.should eq("text/csv; charset=utf-8; header=present")
        response.headers["Content-Disposition"].should eq("attachment;filename=nps.gov_2014-06-08_2014-06-14.csv")
        response.body.should start_with("Search Term,Real (Humans only) Queries,Real Clicks,Real CTR,Total (Bots + Humans) Queries,Total Clicks,Total CTR\njobs,9,15,166.7%,10,15,150.0%\nchartres,1,20,2000.0%,1,1,100.0%\n")
        response.body.should contain("filing complaints on us priviate militaires companies,0,0,--,8,12,150.0%")
      end
    end
  end
end
