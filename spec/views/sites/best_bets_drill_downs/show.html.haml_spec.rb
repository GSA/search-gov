require 'spec_helper'

describe "sites/best_bets_drill_downs/show.html.haml" do
  fixtures :affiliates, :users, :search_modules, :boosted_contents
  let(:site) { affiliates(:basic_affiliate) }
  let(:bbdd) { SearchModuleDrillDown.new(site, 'BOOS') }

  before do
    activate_authlogic
    assign :site, site
    affiliate_user = users(:affiliate_manager)
    UserSession.create(affiliate_user)
    view.stub!(:current_user).and_return affiliate_user
    bcs = {boosted_contents(:basic).id => { model: boosted_contents(:basic), impression_count: 4, click_count: 1, clickthru_ratio: 25.0 },
           boosted_contents(:another).id => { model: boosted_contents(:another), impression_count: 5, click_count: 0, clickthru_ratio: 0.0 }}
    bbdd.stub(:search_module_stats).and_return bcs
    assign :best_bets_drill_down, bbdd
  end

  context 'regardless of the data available' do
    it "should show the header for the current month" do
      render
      rendered.should contain "Best Bets Text Drilldown for Current Month"
      rendered.should contain "Impressions and Clicks by Best Bet"
    end

    context 'when help link is available' do
      before do
        HelpLink.stub(:find_by_request_path).and_return stub_model(HelpLink, request_path: '/sites/best_bets_drill_downs', help_page_url: 'http://www.help.gov/')
      end

      it "should show help link" do
        render
        rendered.should have_selector("a.help-link.menu", href: 'http://www.help.gov/', content: 'Help Manual')
      end
    end
  end

  context 'when impressions and clicks are available for the current month' do
    before do
      render
    end

    it 'should show the breakdown by module and comparison to overall average' do
      rendered.should have_selector("table tbody tr", count: 2) do |rows|
        rows[0].should contain "my boosted content (edit) 4 (drill down) 1 25.0%"
        rows[0].should have_selector("a", content: '(edit)', href: "/sites/#{site.id}/best_bets_texts/#{boosted_contents(:basic).id}/edit")
        rows[1].should contain "something else (edit) 5 (drill down) 0 0.0%"
        rows[1].should have_selector("a", content: '(edit)', href: "/sites/#{site.id}/best_bets_texts/#{boosted_contents(:another).id}/edit")
      end
    end
  end

end
