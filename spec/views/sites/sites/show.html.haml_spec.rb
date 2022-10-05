require 'spec_helper'

describe 'sites/sites/show.html.haml', pending: 'SRCH-3404' do
  fixtures :affiliates, :users
  let(:site) { affiliates(:basic_affiliate) }

  before do
    activate_authlogic
    assign :site, site
    @affiliate_user = users(:affiliate_manager)
    UserSession.create(@affiliate_user)
    allow(view).to receive(:current_user).and_return @affiliate_user
  end

  context 'when affiliate user views the dashboard' do
    context 'regardless of the data available' do
      before do
        assign :dashboard, double('RtuDashboard').as_null_object
      end

      it 'should show header' do
        render
        expect(rendered).to have_content %{Today's Snapshot}
      end

      context 'when help link is available' do
        before do
          allow(HelpLink).to receive(:find_by_request_path).and_return stub_model(HelpLink, request_path: '/sites', help_page_url: 'http://www.help.gov/')
        end

        it 'should show help link' do
          render
          expect(rendered).to have_selector("a.help-link.menu[href='http://www.help.gov/']", text: 'Help Manual')
        end
      end
    end

    context 'when Discovery Tag trending URLs are available for today' do
      let(:trending_urls) { %w[http://www.gov.gov/url1.html http://www.gov.gov/this/url/is/really/extremely/long/for/some/reason/url2.html] }

      before do
        assign :dashboard, double('RtuDashboard', trending_urls: trending_urls).as_null_object
      end

      it 'should show them truncated in an ordered list without URL protocol' do
        render
        expect(rendered).to have_selector('h3', text: 'Trending URLs')
        expect(rendered).to have_selector('ol#trending_urls li', count: 2) do |lis|
          expect(lis[0]).to have_selector('a', text: 'www.gov.gov/url1.html', href: trending_urls[0])
          expect(lis[1]).to have_selector("a[href=\"#{trending_urls[1]}\"]", text: 'www.gov.gov/this/url/is/really/.../long/for/some/reason/url2.html')
        end
      end

    end

    context 'when no-result queries are available for today' do
      before do
        no_results = [QueryCount.new('nr1', 100), QueryCount.new('nr2', 50)]
        assign :dashboard, double('RtuDashboard', no_results: no_results).as_null_object
      end

      it 'should show them in an ordered list' do
        render
        expect(rendered).to have_selector('h3', text: 'Queries with No Results')
        expect(rendered).to have_selector('ol#no_results') do |ol|
          expect(ol).to have_content %{nr1 [100]}
          expect(ol).to have_content %{nr2 [50]}
        end
      end
    end

    context 'when no no-result queries are available for today' do
      before do
        assign :dashboard, double('RtuDashboard', no_results: nil).as_null_object
      end

      it 'should display a message explaining there are none' do
        render
        expect(rendered).to have_selector('h3', text: 'Queries with No Results')
        expect(rendered).to have_selector('p') do |p|
          expect(p).to have_content 'Not enough query data available'
        end
      end
    end

    context 'when top clicked URLs are available for today' do
      before do
        top_urls = {'http://www.gov.gov/clicked_url4.html' => 20, 'http://www.gov.gov/this/url/is/really/extremely/long/for/some/reason/clicked_url5.html' => 10}
        assign :dashboard, double('RtuDashboard', top_urls: top_urls).as_null_object
      end

      it 'should show them in an ordered list' do
        render
        expect(rendered).to have_selector('h3', text: 'Top Clicked URLs')
        expect(rendered).to have_selector('ol#top_urls li', count: 2) do |lis|
          expect(lis[0].inner_text).to eq('www.gov.gov/clicked_url4.html [20]')
          expect(lis[1].inner_text).to eq('www.gov.gov/this/url/is/really/.../some/reason/clicked_url5.html [10]')
          expect(lis[0]).to have_selector("a[href='http://www.gov.gov/clicked_url4.html']", text: 'www.gov.gov/clicked_url4.html')
          expect(lis[1]).to have_selector("a[href='http://www.gov.gov/this/url/is/really/extremely/long/for/some/reason/clicked_url5.html']", text: 'www.gov.gov/this/url/is/really/.../some/reason/clicked_url5.html')
        end
      end
    end

    context 'when top clicked URLs are not available for today' do
      before do
        top_urls = {}
        assign :dashboard, double('RtuDashboard', top_urls: top_urls).as_null_object
      end

      it 'should say something about insufficient content' do
        render
        expect(rendered).to have_selector('h3', text: 'Top Clicked URLs')
        expect(rendered).to have_content /Not enough click data available/
      end
    end

    context 'when top queries are available for today' do
      before do
        top_queries = [['jobs', 54, 53], ['economy', 55, 43], ['ebola', 53, 42]]
        assign :dashboard, double('RtuDashboard', top_queries: top_queries).as_null_object
      end

      context 'when user has sees_filtered_totals setting enabled' do
        before do
          @affiliate_user.sees_filtered_totals = true
        end

        it 'should show them in an ordered list' do
          render
          expect(rendered).to have_selector('h3', text: 'Top Queries')
          expect(rendered).to have_selector('ol#top_queries') do |ol|
            expect(ol).to have_content %{jobs [53]}
            expect(ol).to have_content %{economy [43]}
            expect(ol).to have_content %{ebola [42]}
          end
        end
      end

      context 'when user has sees_filtered_totals setting disabled' do
        before do
          @affiliate_user.sees_filtered_totals = false
        end

        it 'should show them in an ordered list' do
          render
          expect(rendered).to have_selector('h3', text: 'Top Queries')
          expect(rendered).to have_selector('ol#top_queries') do |ol|
            expect(ol).to have_content %{jobs [54]}
            expect(ol).to have_content %{economy [55]}
            expect(ol).to have_content %{ebola [53]}
          end
        end
      end
    end

    context 'when low CTR queries are available for today' do
      before do
        low_ctr_queries = [
          ['seldom', 5.1234],
          ['rare', 2.000],
          ['never', 0]
        ]
        assign :dashboard, double('RtuDashboard', low_ctr_queries: low_ctr_queries).as_null_object
      end

      it 'should show them in an ordered list' do
        render
        expect(rendered).to have_selector('h3', text: 'Top Queries with Low Click Thrus')
        expect(rendered).to have_selector('ol#low_ctr_queries') do |ol|
          expect(ol).to have_content %{seldom [5.1%]}
          expect(ol).to have_content %{rare [2%]}
          expect(ol).to have_content %{never [0%]}
        end
      end
    end

    context 'when no low CTR queries are available for today' do
      before do
        assign :dashboard, double('RtuDashboard', low_ctr_queries: nil).as_null_object
      end

      it 'should display a message indicating there isn\'t enough data' do
        render
        expect(rendered).to have_selector('h3', text: 'Top Queries with Low Click Thrus')
        expect(rendered).to have_selector('p') do |p|
          expect(p).to have_content 'Not enough query data available'
        end
      end
    end

    context 'when trending queries are available for today' do
      before do
        trending_queries = %w{obama jobs economy}
        assign :dashboard, double('RtuDashboard', trending_queries: trending_queries).as_null_object
      end

      it 'should show them in an ordered list' do
        render
        expect(rendered).to have_selector('h3', text: 'Trending Queries')
        expect(rendered).to have_selector('ol#trending_queries') do |ol|
          expect(ol).to have_content /jobs/
          expect(ol).to have_content /economy/
          expect(ol).to have_content /obama/
        end
      end
    end

    describe '#monthly_usage_chart' do
      context 'when usage chart is available' do
        before do
          chart = double('Google Chart', to_js: '')
          assign :dashboard, double('RtuDashboard', monthly_usage_chart: chart).as_null_object
        end

        it 'should show the Google chart' do
          render
          expect(rendered).to have_selector('#chart')
        end
      end
    end

    context 'when showing month-to-date usage totals' do
      let(:formatted_beginning_of_month) { Date.current.beginning_of_month.to_formatted_s(:long).squish }
      let(:formatted_today) { Date.current.to_formatted_s(:long).squish }

      before do
        assign :dashboard, double('RtuDashboard', monthly_queries_to_date: 12_345, monthly_clicks_to_date: 5678).as_null_object
      end

      it 'should show the totals in a month-to-date div' do
        render
        expect(rendered).to have_selector('h3', text: "This Month's Totals to Date")
        expect(rendered).to have_selector('p', text: "Dates: #{formatted_beginning_of_month} - #{formatted_today}")
        expect(rendered).to have_selector('p', text: 'Total Queries: 12,345')
        expect(rendered).to have_selector('p', text: 'Total Clicks: 5,678')
      end
    end
  end
end
