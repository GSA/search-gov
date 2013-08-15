require 'spec_helper'

describe "sites/sites/show.html.haml" do
  fixtures :affiliates, :users
  let(:site) { affiliates(:basic_affiliate) }

  before do
    activate_authlogic
    assign :site, site
    affiliate_user = users(:affiliate_manager)
    UserSession.create(affiliate_user)
    view.stub!(:current_user).and_return affiliate_user
  end

  context "when affiliate user views the dashboard" do
    context 'regardless of the data available' do
      before do
        assign :dashboard, double('Dashboard').as_null_object
      end

      it "should show header" do
        render
        rendered.should contain %{Today's Snapshot}
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

    context 'when Discovery Tag trending URLs are available for today' do
      let(:trending_urls) { %w[http://www.gov.gov/url1.html http://www.gov.gov/this/url/is/really/long/for/some/reason/url2.html] }

      before do
        assign :dashboard, double('Dashboard', trending_urls: trending_urls).as_null_object
      end

      it 'should show them truncated in an ordered list without URL protocol' do
        render
        rendered.should have_selector("h3", content: "Trending URLs")
        rendered.should have_selector("ol#trending_urls li", count: 2) do |lis|
          lis[0].should have_selector("a", content: 'www.gov.gov/url1.html', href: trending_urls[0])
          lis[1].should have_selector("a", content: 'www.gov.gov/this/url/.../reason/url2.html', href: trending_urls[1])
        end
      end

    end

    context 'when no-result queries are available for today' do
      before do
        DailyQueryNoresultsStat.create!(:day => Date.current, :query => 'nr1', :times => 100, :affiliate => site.name)
        DailyQueryNoresultsStat.create!(:day => Date.current, :query => 'nr2', :times => 50, :affiliate => site.name)
        no_results = DailyQueryNoresultsStat.most_popular_no_results_queries(Date.current, Date.current, 10, site.name)
        assign :dashboard, double('Dashboard', no_results: no_results).as_null_object
      end

      it 'should show them in an ordered list' do
        render
        rendered.should have_selector("h3", content: "Queries with No Results")
        rendered.should have_selector("ol#no_results") do |ol|
          ol.should contain %{nr1 [100]}
          ol.should contain %{nr2 [50]}
        end
      end
    end

    context 'when top clicked URLs are available for today' do
      before do
        DailyClickStat.create!(:day => Date.current, :url => 'http://www.gov.gov/clicked_url4.html', :times => 20, :affiliate => site.name)
        DailyClickStat.create!(:day => Date.current, :url => 'http://www.gov.gov/this/url/is/really/long/for/some/reason/clicked_url5.html', :times => 10, :affiliate => site.name)
        top_urls = DailyClickStat.top_urls(site.name, Date.current, Date.current, 10)
        assign :dashboard, double('Dashboard', top_urls: top_urls).as_null_object
      end

      it 'should show them in an ordered list' do
        render
        rendered.should have_selector("h3", content: "Top Clicked URLs")
        rendered.should have_selector("ol#top_urls li", count: 2) do |lis|
          lis[0].inner_text.should == 'www.gov.gov/clicked_url4.html [20]'
          lis[1].inner_text.should == 'www.gov.gov/this/.../clicked_url5.html [10]'
          lis[0].should have_selector("a", content: 'www.gov.gov/clicked_url4.html', href: 'http://www.gov.gov/clicked_url4.html')
          lis[1].should have_selector("a", content: 'www.gov.gov/this/.../clicked_url5.html', href: 'http://www.gov.gov/this/url/is/really/long/for/some/reason/clicked_url5.html')
        end
      end
    end

    context 'when top clicked URLs are not available for today' do
      before do
        DailyClickStat.delete_all
        top_urls = DailyClickStat.top_urls(site.name, Date.current, Date.current, 10)
        assign :dashboard, double('Dashboard', top_urls: top_urls).as_null_object
      end

      it 'should say something about insufficient content' do
        render
        rendered.should have_selector("h3", content: "Top Clicked URLs")
        rendered.should contain /Not enough click data available/
      end
    end

    context 'when top queries are available for today' do
      before do
        DailyQueryStat.create!(:day => Date.current, :query => 'jobs', :times => 20, :affiliate => site.name)
        DailyQueryStat.create!(:day => Date.current, :query => 'economy', :times => 10, :affiliate => site.name)
        top_queries = DailyQueryStat.most_popular_terms(site.name, Date.current, Date.current, 10)
        assign :dashboard, double('Dashboard', top_queries: top_queries).as_null_object
      end

      it 'should show them in an ordered list' do
        render
        rendered.should have_selector("h3", content: "Top Queries")
        rendered.should have_selector("ol#top_queries") do |ol|
          ol.should contain %{jobs [20]}
          ol.should contain %{economy [10]}
        end
      end
    end

    context 'when low CTR queries are available for today' do
      before do
        low_ctr_queries = [
          ['seldom', 5],
          ['rare', 2],
          ['never', 0]
        ]
        DailyQueryStat.stub(:low_ctr_queries).with(site.name).and_return low_ctr_queries
        assign :dashboard, double('Dashboard', low_ctr_queries: low_ctr_queries).as_null_object
      end

      it 'should show them in an ordered list' do
        render
        rendered.should have_selector("h3", content: "Top Queries with Low Click Thrus")
        rendered.should have_selector("ol#low_ctr_queries") do |ol|
          ol.should contain %{seldom [5%]}
          ol.should contain %{rare [2%]}
          ol.should contain %{never [0%]}
        end
      end
    end

    context 'when trending queries are available for today' do
      before do
        trending_queries = %w{obama jobs economy}
        assign :dashboard, double('Dashboard', trending_queries: trending_queries).as_null_object
      end

      it 'should show them in an ordered list' do
        render
        rendered.should have_selector("h3", content: "Trending Queries")
        rendered.should have_selector("ol#trending_queries") do |ol|
          ol.should contain /jobs/
          ol.should contain /economy/
          ol.should contain /obama/
        end
      end
    end

    describe '#monthly_usage_chart' do
      context 'when usage chart is available' do
        before do
          chart = double('Google Chart', to_js: '')
          assign :dashboard, double('Dashboard', monthly_usage_chart: chart).as_null_object
        end

        it 'should show the Google chart' do
          render
          rendered.should have_selector("#chart")
        end
      end
    end

    context 'when showing month-to-date usage totals' do
      let(:formatted_beginning_of_month) { Date.current.beginning_of_month.to_formatted_s(:long).squish }
      let(:formatted_today) { Date.current.to_formatted_s(:long).squish }

      before do
        assign :dashboard, double('Dashboard', monthly_queries_to_date: 12345, monthly_clicks_to_date: 5678).as_null_object
      end

      it 'should show the totals in a month-to-date div' do
        render
        rendered.should have_selector("h3", content: "This Month's Totals to Date")
        rendered.should have_selector("p", content: "Dates: #{formatted_beginning_of_month} - #{formatted_today}")
        rendered.should have_selector("p", content: "Total Queries: 12,345")
        rendered.should have_selector("p", content: "Total Clicks: 5,678")
      end
    end

  end
end
