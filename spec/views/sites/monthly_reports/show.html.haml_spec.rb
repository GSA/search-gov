require 'spec_helper'

describe "sites/monthly_reports/show.html.haml" do
  fixtures :affiliates, :users, :search_modules
  let(:site) { affiliates(:basic_affiliate) }

  before do
    activate_authlogic
    assign :site, site
    affiliate_user = users(:affiliate_manager)
    UserSession.create(affiliate_user)
    view.stub!(:current_user).and_return affiliate_user
  end

  describe 'legacy monthly report behavior' do
    let(:target_date) { Date.parse('2013-09-11') }

    before do
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

  context "when affiliate user views the monthly report page" do
    context 'regardless of the data available' do
      before do
        assign :monthly_report, RtuMonthlyReport.new(site, 2014, 6, true)
      end

      it "should show header" do
        render
        rendered.should contain %{Monthly Usage Stats for June 2014}
      end

      context 'when help link is available' do
        before do
          HelpLink.stub(:find_by_request_path).and_return stub_model(HelpLink, request_path: '/sites', help_page_url: 'http://www.help.gov/')
        end

        it "should show help link" do
          render
          rendered.should have_selector("a.help-link.menu", href: 'http://www.help.gov/', content: "Help?")
        end
      end
    end

    context 'when there is data' do
      before do
        monthly_report = RtuMonthlyReport.new(site, 2014, 6, true)
        monthly_report.stub(:total_queries).and_return 12345
        monthly_report.stub(:total_clicks).and_return 5678
        stats = []
        stats << OpenStruct.new(display_name: 'Bing', clicks: 80, impressions: 100,
                                clickthru_ratio: 80, historical_ctr: [25, 26],
                                module_tag: 'BWEB', average_clickthru_ratio: 75)
        stats << OpenStruct.new(display_name: "Total", clicks: 1000, impressions: 2000,
                                clickthru_ratio: 50, historical_ctr: [40, 45])

        monthly_report.stub(:search_module_stats).and_return stats
        assign :monthly_report, monthly_report
      end

      it 'should show the monthly usage totals' do
        render
        rendered.should have_selector("dd", content: "12,345")
        rendered.should have_selector("dd", content: "5,678")
        rendered.should have_selector("td", content: "Bing")
        rendered.should have_selector("td", content: "80")
        rendered.should have_selector("td", content: "100")
        rendered.should have_selector("td", content: "80.0%")
        rendered.should have_selector("td", content: "75.0%")
        rendered.should have_selector("td", content: "Total")
        rendered.should have_selector("td", content: "2,000")
        rendered.should have_selector("td", content: "1,000")
        rendered.should have_selector("td", content: "50.0%")
      end

      it 'should show download links' do
        render
        rendered.should contain("Download top queries for June 2014 (csv)")
        rendered.should contain("Download top queries for the week of 2014-06-01 (csv)")
        rendered.should contain("Download top queries for the week of 2014-06-08 (csv)")
        rendered.should contain("Download top queries for the week of 2014-06-15 (csv)")
        rendered.should contain("Download top queries for the week of 2014-06-22 (csv)")
      end
    end

    context 'when there is no data' do
      before do
        monthly_report = RtuMonthlyReport.new(site, 2014, 6, true)
        monthly_report.stub(:total_queries).and_return 0
        monthly_report.stub(:total_clicks).and_return 0
        monthly_report.stub(:search_module_stats).and_return []
        assign :monthly_report, monthly_report
      end

      it 'should show the totals' do
        render
        rendered.should have_selector("dd", content: "0")
        rendered.should have_selector("dd", content: "n/a")
      end
    end
  end
end
