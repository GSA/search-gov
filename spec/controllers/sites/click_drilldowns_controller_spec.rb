# frozen_string_literal: true

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
      let(:query_args) do
        [
          site.name,
          Date.new(2015,02,01),
          Date.new(2015,02,05),
          'params.url',
          'http://some.gov.url/super_long_so_truncate_at_50/blah.cfm',
          'click'
        ]
      end
      let(:query) { instance_double(DrilldownQuery, body: '') }

      before do
        expect(DrilldownQuery).to receive(:new).with(*query_args).
          and_return(query)
        allow(ES::ELK.client_reader).to receive(:search).
          and_return(drilldown_clicks_response)
      end

      it 'generates a CSV of various click fields' do
        get :show,
            params: {
              site_id: site.id,
              url: 'http://some.gov.url/super_long_so_truncate_at_50/blah.cfm',
              start_date: '2015-02-01', end_date: '2015-02-05'
            },
            format: 'csv'

        expect(response.media_type).to eq('text/csv')
        expect(response.headers['Content-Disposition']).to eq('attachment;filename=nps.gov_http://some.gov.url/super_long_so_truncate_at_50/b_2015-02-01_2015-02-05.csv')
        expect(response.body).to eq(read_fixture_file('/csv/click_drilldown.csv'))
      end
    end
  end
end
