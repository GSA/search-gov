require 'spec_helper'

describe Sites::ClickDrilldownsController do
  render_views
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show' do
    it_should_behave_like 'restricted to approved user', :get, :show, site_id: 100

    context 'when affiliate is downloading click CSV data' do
      include_context 'approved user logged in to a site'
      let(:drilldown_clicks_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/drilldown_clicks.json")) }

      before do
        allow(ES::ELK.client_reader).to receive(:search).and_return(drilldown_clicks_response)
      end

      it 'should generate a CSV of various click fields' do
        get :show, site_id: site.id, url:'http://some.gov.url/super_long_so_truncate_at_50/blah.cfm', start_date: '2015-02-01', end_date: '2015-02-05', format: 'csv'
        expect(response.content_type).to eq('text/csv')
        expect(response.headers["Content-Disposition"]).to eq("attachment;filename=nps.gov_http://some.gov.url/super_long_so_truncate_at_50/b_2015-02-01_2015-02-05.csv")
        expect(response.body).to start_with(Sites::ClickDrilldownsController::HEADER_FIELDS.to_csv)
        expect(response.body).to have_content("2015-02-01,10:23:58,the constitution and the bill of rights,2,/clicked?a=usagov&l=en&q=the+constitution+and+the+bill+of+rights&s=BWEB&t=1422786234&v=web&u=http%3A%2F%2Fwww.archives.gov%2Fexhibits%2Fcharters%2Fbill_of_rights.html&p=2,https://search.usa.gov/search?affiliate=usagov&query=the+constitution+and+the+bill+of+rights,web,BWEB,Other,Chrome,Windows,US,SC,206.53.115.243,\"Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.93 Safari/537.36\"")
      end
    end
  end
end
