require 'spec_helper'

describe "sites/monthly_reports/show.html.haml" do
  fixtures :affiliates, :users, :search_modules
  let(:site) { affiliates(:basic_affiliate) }
  let(:target_date) { Date.parse('2013-09-11') }

  before do
    activate_authlogic
    assign :site, site
    affiliate_user = users(:affiliate_manager)
    UserSession.create(affiliate_user)
    view.stub!(:current_user).and_return affiliate_user
    AWS::S3::S3Object.stub(:url_for).and_return "http://dummy/"
    AWS::S3::S3Object.stub(:exists?).and_return true
    DailyUsageStat.delete_all
    DailySearchModuleStat.delete_all
    assign :monthly_report, MonthlyReport.new(site, target_date.year, target_date.month)
  end

  context 'regardless of the data available' do
    it "should show the header for the current month" do
      render
      rendered.should contain "Monthly Usage Stats for #{Date::MONTHNAMES[target_date.month]} #{target_date.year}"
    end

    context 'when help link is available' do
      before do
        HelpLink.stub(:find_by_request_path).and_return stub_model(HelpLink, request_path: '/sites/monthly_reports', help_page_url: 'http://www.help.gov/')
      end

      it "should show help link" do
        render
        rendered.should have_selector("a.help-link.menu", href: 'http://www.help.gov/', content: "Help?")
      end
    end
  end

  context 'when queries and clicks are available for the month' do
    let(:other_site) { affiliates(:power_affiliate) }

    before do
      DailyUsageStat.create!(:day => target_date.beginning_of_month, :total_queries => 100, :affiliate => site.name)
      DailyUsageStat.create!(:day => target_date.end_of_month, :total_queries => 1000, :affiliate => site.name)

      DailySearchModuleStat.create!(:day => target_date.beginning_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'BWEB', :clicks => 123, :impressions => 1289)
      DailySearchModuleStat.create!(:day => target_date.end_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'BWEB', :clicks => 878, :impressions => 6189)
      DailySearchModuleStat.create!(:day => target_date.end_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'VIDEO', :clicks => 67, :impressions => 671)
      DailySearchModuleStat.create!(:day => target_date.beginning_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'VIDEO', :clicks => 12, :impressions => 129)
      DailySearchModuleStat.create!(:day => target_date.beginning_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'BOOS', :clicks => 41, :impressions => 42)
      DailySearchModuleStat.create!(:day => target_date.beginning_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'BBG', :clicks => 51, :impressions => 52)
      DailySearchModuleStat.create!(:day => target_date.end_of_month, :affiliate_name => other_site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'BWEB', :clicks => 100, :impressions => 200)
      DailySearchModuleStat.create!(:day => target_date.end_of_month, :affiliate_name => other_site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'VIDEO', :clicks => 333, :impressions => 1000)
      render
    end

    it 'should show the monthy query and click totals' do
      rendered.should have_selector("#queries_clicks") do |snippet|
        snippet.should contain "1,100"
        snippet.should contain "1,172"
      end
    end

    it 'should show the breakdown by module and comparison to overall average' do
      rendered.should have_selector("#by_module tr", count: 6) do |rows|
        rows[0].should contain "Module Impressions Clicks Your CTR Average CTR"
        rows[1].should contain "Bing Web 7,478 1,001 13.4% 14.3%"
        rows[2].should contain "Bing Video 800 79 9.9% 22.9%"
        rows[3].should contain "Best Bets Graphic (drill down) 52 51 98.1%"
        rows[3].should have_selector("a", content: '(drill down)', href: "/sites/#{site.id}/best_bets_drill_down?module_tag=BBG")
        rows[4].should contain "Best Bets Text (drill down) 42 41 97.6%"
        rows[4].should have_selector("a", content: '(drill down)', href: "/sites/#{site.id}/best_bets_drill_down?module_tag=BOOS")
        rows[5].should contain "Total 8,372 1,172 14.0%"
      end
    end
  end

  context 'when only queries are available for the month (e.g., API customer)' do
    let(:other_site) { affiliates(:power_affiliate) }

    before do
      DailyUsageStat.create!(:day => target_date.beginning_of_month, :total_queries => 100, :affiliate => site.name)

      DailySearchModuleStat.create!(:day => target_date.beginning_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'BWEB', :clicks => 0, :impressions => 1289)
      DailySearchModuleStat.create!(:day => target_date.end_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'BWEB', :clicks => 0, :impressions => 6189)
      DailySearchModuleStat.create!(:day => target_date.end_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'VIDEO', :clicks => 0, :impressions => 671)
      DailySearchModuleStat.create!(:day => target_date.beginning_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'VIDEO', :clicks => 0, :impressions => 129)
      DailySearchModuleStat.create!(:day => target_date.beginning_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'BOOS', :clicks => 0, :impressions => 42)
      DailySearchModuleStat.create!(:day => target_date.beginning_of_month, :affiliate_name => site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'BBG', :clicks => 0, :impressions => 52)
      DailySearchModuleStat.create!(:day => target_date.end_of_month, :affiliate_name => other_site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'BWEB', :clicks => 100, :impressions => 200)
      DailySearchModuleStat.create!(:day => target_date.end_of_month, :affiliate_name => other_site.name, :locale => 'en',
                                    :vertical => 'web', :module_tag => 'VIDEO', :clicks => 333, :impressions => 1000)
      render
    end

    it 'should show the click total as n/a' do
      rendered.should have_selector("#queries_clicks") do |snippet|
        snippet.should contain "Total Clicks n/a"
      end
    end

    it 'should show the click breakdowns by module as n/a with a blank for the CTR column, ordered by impression count' do
      rendered.should have_selector("#by_module tr", count: 6) do |rows|
        rows[0].should contain "Module Impressions Clicks Your CTR Average CTR"
        rows[1].should contain "Bing Web 7,478 n/a 1.3%"
        rows[2].should contain "Bing Video 800 n/a 18.5%"
        rows[3].should contain "Best Bets Graphic (drill down) 52 n/a 0.0%"
        rows[4].should contain "Best Bets Text (drill down) 42 n/a 0.0%"
        rows[5].should contain "Total 8,372 n/a"
      end
    end
  end

  context 'when report links are available' do
    before do
      render
    end

    it 'should list them out' do
      rendered.should have_selector("ul#report_links li", count: 6) do |lis|
        lis[0].should contain "Download top queries for September 2013"
        lis[1].should contain "Download top queries for the week of 2013-09-01"
        lis[2].should contain "Download top queries for the week of 2013-09-08"
        lis[3].should contain "Download top queries for the week of 2013-09-15"
        lis[4].should contain "Download top queries for the week of 2013-09-22"
        lis[5].should contain "Download top queries for the week of 2013-09-29"
        lis.each { |li| li.should have_selector("a", content: 'csv') }
      end
    end
  end

end
