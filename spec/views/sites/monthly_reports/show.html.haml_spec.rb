require 'spec_helper'

describe "sites/monthly_reports/show.html.haml" do
  fixtures :affiliates, :users, :search_modules
  let(:site) { affiliates(:basic_affiliate) }

  before do
    activate_authlogic
    assign :site, site
    affiliate_user = users(:affiliate_manager)
    UserSession.create(affiliate_user)
    allow(view).to receive(:current_user).and_return affiliate_user
  end

  context "when affiliate user views the monthly report page" do
    context 'regardless of the data available' do
      before do
        assign :monthly_report, RtuMonthlyReport.new(site, 2014, 6, true)
      end

      it "should show header" do
        render
        expect(rendered).to have_content %{Monthly Usage Stats for June 2014}
      end

      context 'when help link is available' do
        before do
          allow(HelpLink).to receive(:find_by_request_path).and_return stub_model(HelpLink, request_path: '/sites', help_page_url: 'http://www.help.gov/')
        end

        it "should show help link" do
          render
          expect(rendered).to have_selector("a.help-link.menu[href='http://www.help.gov/']", text: "Help Manual")
        end
      end
    end

    context 'when there is data' do
      before do
        monthly_report = RtuMonthlyReport.new(site, 2014, 6, true)
        allow(monthly_report).to receive(:total_queries).and_return 12345
        allow(monthly_report).to receive(:total_clicks).and_return 5678

        no_result_queries = [['peanut butter', 4], ['chocolate', 8]]
        allow(monthly_report).to receive(:no_result_queries).and_return no_result_queries

        low_ctr_queries = [['apples', 15], ['bananas', 18]]
        allow(monthly_report).to receive(:low_ctr_queries).and_return low_ctr_queries

        stats = []
        stats << OpenStruct.new(display_name: 'Bing', clicks: 80, impressions: 100,
                                clickthru_ratio: 80, historical_ctr: [25, 26],
                                module_tag: 'BWEB', average_clickthru_ratio: 75)
        stats << OpenStruct.new(display_name: "Total", clicks: 1000, impressions: 2000,
                                clickthru_ratio: 50, historical_ctr: [40, 45])

        allow(monthly_report).to receive(:search_module_stats).and_return stats
        assign :monthly_report, monthly_report
      end

      it 'should show no-result queries' do
        render
        expect(rendered).to have_selector("h3", text: "Queries with No Results")
        expect(rendered).to have_selector("ol#no_result_queries")
        expect(rendered).to have_selector('ol#no_result_queries li', text: %{peanut butter [4]})
        expect(rendered).to have_selector('ol#no_result_queries li', text: %{chocolate [8]})
      end

      it 'should show low-ctr queries' do
        render
        expect(rendered).to have_selector("h3", text: "Queries with Low Click Thrus")
        expect(rendered).to have_selector("ol#low_ctr_queries")
        expect(rendered).to have_selector("ol#low_ctr_queries li", text: %{apples [15%]})
        expect(rendered).to have_selector("ol#low_ctr_queries li", text: %{bananas [18%]})
      end

      it 'should show the monthly usage totals' do
        render
        expect(rendered).to have_selector("dd", text: "12,345")
        expect(rendered).to have_selector("dd", text: "5,678")
        expect(rendered).to have_selector("td", text: "Bing")
        expect(rendered).to have_selector("td", text: "80")
        expect(rendered).to have_selector("td", text: "100")
        expect(rendered).to have_selector("td", text: "80.0%")
        expect(rendered).to have_selector("td", text: "75.0%")
        expect(rendered).to have_selector("td", text: "Total")
        expect(rendered).to have_selector("td", text: "2,000")
        expect(rendered).to have_selector("td", text: "1,000")
        expect(rendered).to have_selector("td", text: "50.0%")
      end

      it 'should show download links' do
        render
        expect(rendered).to have_content("Download top queries for June 2014 (csv)")
        expect(rendered).to have_content("Download top queries for the week of 2014-06-01 (csv)")
        expect(rendered).to have_content("Download top queries for the week of 2014-06-08 (csv)")
        expect(rendered).to have_content("Download top queries for the week of 2014-06-15 (csv)")
        expect(rendered).to have_content("Download top queries for the week of 2014-06-22 (csv)")
      end
    end

    context 'when there is no data' do
      before do
        monthly_report = RtuMonthlyReport.new(site, 2014, 6, true)
        allow(monthly_report).to receive(:total_queries).and_return 0
        allow(monthly_report).to receive(:total_clicks).and_return 0
        allow(monthly_report).to receive(:no_result_queries).and_return nil
        allow(monthly_report).to receive(:low_ctr_queries).and_return nil
        allow(monthly_report).to receive(:search_module_stats).and_return []
        assign :monthly_report, monthly_report
      end

      it 'should display a message indicating not enough data for no-result queries' do
        render
        expect(rendered).to have_selector('h3', text: 'Queries with No Results')
        expect(rendered).to have_selector('p', text: 'Not enough query data available')
      end

      it 'should display a message indicating not enough data for low-ctr queries' do
        render
        expect(rendered).to have_selector('h3', text: 'Queries with Low Click Thrus')
        expect(rendered).to have_selector('p', text: 'Not enough query data available')
      end

      it 'should show the totals' do
        render
        expect(rendered).to have_selector("dd", text: "0")
        expect(rendered).to have_selector("dd", text: "n/a")
      end
    end
  end
end
