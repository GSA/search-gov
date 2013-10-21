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

      render
    end

    it 'should show the monthy query and click totals' do
      rendered.should have_selector("#queries_clicks") do |snippet|
        snippet.should contain "1,100"
        snippet.should contain "1,080"
      end
    end

    it 'should show the breakdown by module' do
      rendered.should have_selector("#by_module") do |snippet|
        snippet.should contain "Module"
        snippet.should contain "Impressions"
        snippet.should contain "Clicks"
        snippet.should contain "Clickthru Rate"
        snippet.should contain "Bing Web"
        snippet.should contain "7,478"
        snippet.should contain "1,001"
        snippet.should contain "13.4%"
        snippet.should contain "Bing Video"
        snippet.should contain "800"
        snippet.should contain "79"
        snippet.should contain "9.9%"
        snippet.should contain "Total"
        snippet.should contain "8,278"
        snippet.should contain "1,080"
        snippet.should contain "13.0%"
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
        lis.each {|li| li.should have_selector("a", content: 'csv') }
      end
    end
  end

end
