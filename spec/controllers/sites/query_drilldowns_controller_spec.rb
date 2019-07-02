require 'spec_helper'

describe Sites::QueryDrilldownsController do
  render_views
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show, site_id: 100

    context 'when affiliate is downloading query CSV data' do
      include_context 'approved user logged in to a site'
      let(:drilldown_queries_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/drilldown_queries.json")) }

      before do
        allow(ES::ELK.client_reader).to receive(:search).and_return(drilldown_queries_response)
      end

      it 'should generate a CSV of various query fields' do
        get :show, query:'foo bar', start_date: '2015-02-01', end_date: '2015-02-05', format: 'csv', site_id: site.id
        expect(response.content_type).to eq('text/csv')
        expect(response.headers["Content-Disposition"]).to eq("attachment;filename=nps.gov_foo_bar_2015-02-01_2015-02-05.csv")
        expect(response.body).to start_with(Sites::QueryDrilldownsController::HEADER_FIELDS.to_csv)
        expect(response.body).to have_content("2015-02-01,04:52:14,https://search.usa.gov/search?utf8=%E2%9C%93&affiliate=usagov&query=fashion+psychology,https://search.usa.gov/search?affiliate=usagov&query=fashion,web,BWEB BOOS,Other,IE,Windows 7,US,MO,204.184.232.180,Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")
      end
    end
  end
end
