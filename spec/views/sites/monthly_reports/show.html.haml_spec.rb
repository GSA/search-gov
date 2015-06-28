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
          rendered.should have_selector("a.help-link.menu", href: 'http://www.help.gov/', content: 'Help Manual')
        end
      end
    end

    context 'when there is data' do
      before do
        monthly_report = RtuMonthlyReport.new(site, 2014, 6, true)
        monthly_report.stub(:total_queries).and_return 12345
        monthly_report.stub(:total_clicks).and_return 5678

        no_result_queries = [['peanut butter', 4], ['chocolate', 8]]
        monthly_report.stub(:no_result_queries).and_return no_result_queries

        low_ctr_queries = [['apples', 15], ['bananas', 18]]
        monthly_report.stub(:low_ctr_queries).and_return low_ctr_queries

        stats = []
        stats << OpenStruct.new(display_name: 'Bing', clicks: 80, impressions: 100,
                                clickthru_ratio: 80, historical_ctr: [25, 26],
                                module_tag: 'BWEB', average_clickthru_ratio: 75)
        stats << OpenStruct.new(display_name: "Total", clicks: 1000, impressions: 2000,
                                clickthru_ratio: 50, historical_ctr: [40, 45])

        monthly_report.stub(:search_module_stats).and_return stats
        assign :monthly_report, monthly_report
      end

      it 'should show no-result queries' do
        render
        rendered.should have_selector("h3", content: "Queries with No Results")
        rendered.should have_selector("ol#no_result_queries") do |ol|
          ol.should contain %{peanut butter [4]}
          ol.should contain %{chocolate [8]}
        end
      end

      it 'should show low-ctr queries' do
        render
        rendered.should have_selector("h3", content: "Queries with Low Click Thrus")
        rendered.should have_selector("ol#low_ctr_queries") do |ol|
          ol.should contain %{apples [15%]}
          ol.should contain %{bananas [18%]}
        end
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
        monthly_report.stub(:no_result_queries).and_return nil
        monthly_report.stub(:low_ctr_queries).and_return nil
        monthly_report.stub(:search_module_stats).and_return []
        assign :monthly_report, monthly_report
      end

      it 'should display a message indicating not enough data for no-result queries' do
        render
        rendered.should have_selector('h3', content: 'Queries with No Results')
        rendered.should have_selector('p') do |p|
          p.should contain 'Not enough query data available'
        end
      end

      it 'should display a message indicating not enough data for low-ctr queries' do
        render
        rendered.should have_selector('h3', content: 'Queries with Low Click Thrus')
        rendered.should have_selector('p') do |p|
          p.should contain 'Not enough query data available'
        end
      end

      it 'should show the totals' do
        render
        rendered.should have_selector("dd", content: "0")
        rendered.should have_selector("dd", content: "n/a")
      end
    end
  end
end
