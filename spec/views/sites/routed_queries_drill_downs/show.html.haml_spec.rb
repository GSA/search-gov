require 'spec_helper'

describe "sites/routed_queries_drill_downs/show.html.haml" do
  fixtures :affiliates, :users, :search_modules, :routed_queries
  let(:site) { affiliates(:basic_affiliate) }
  let(:rqdd) { SearchModuleDrillDown.new(site, 'QRTD') }

  before do
    activate_authlogic
    assign :site, site
    affiliate_user = users(:affiliate_manager)
    UserSession.create(affiliate_user)
    view.stub(:current_user).and_return affiliate_user
    rqs = {routed_queries(:unclaimed_money).id => { model: routed_queries(:unclaimed_money), impression_count: 6, click_count: 0, clickthru_ratio: 0.0 },
           routed_queries(:moar_unclaimed_money).id => { model: routed_queries(:moar_unclaimed_money), impression_count: 5, click_count: 0, clickthru_ratio: 0.0 }}
    rqdd.stub(:search_module_stats).and_return rqs
    assign :routed_queries_drill_down, rqdd
  end

  context 'regardless of the data available' do
    it "should show the header for the current month" do
      render
      rendered.should contain "Routed Queries Drilldown for Current Month"
      rendered.should contain "Impressions by Routed Query"
    end

    context 'help link is available' do
      before do
        HelpLink.stub(:find_by_request_path).and_return stub_model(HelpLink, request_path: '/sites/routed_queries_drill_downs', help_page_url: 'http://www.help.gov/')
      end

      it "shows help link" do
        render
        rendered.should have_selector("a.help-link.menu", href: 'http://www.help.gov/', content: 'Help Manual')
      end
    end
  end

  context 'impressions are available for the current month' do
    before do
      render
    end

    it 'shows the breakdown by routed query' do
      rendered.should have_selector("table tbody tr", count: 2) do |rows|
        rows[0].should contain "Everybody wants it (edit) 6 (drill down)"
        rows[0].should have_selector("a", content: '(edit)', href: "/sites/#{site.id}/routed_queries/#{routed_queries(:unclaimed_money).id}/edit")
        rows[1].should contain "Seriously they do (edit) 5 (drill down)"
        rows[1].should have_selector("a", content: '(edit)', href: "/sites/#{site.id}/routed_queries/#{routed_queries(:moar_unclaimed_money).id}/edit")
      end
    end
  end

end
