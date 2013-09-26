require 'spec_helper'

describe Dashboard do
  fixtures :affiliates

  let(:site) { affiliates(:basic_affiliate) }
  let(:dashboard) { Dashboard.new(site) }

  describe "#top_queries" do
    context 'when top queries are available' do
      let(:query_counts) { [QueryCount.new('jobs', 100), QueryCount.new('economy', 50)] }

      before do
        DailyQueryStat.stub(:most_popular_terms).and_return query_counts
      end

      it 'should return an array of QueryCount instances' do
        dashboard.top_queries.should == query_counts
      end
    end

    context 'when top queries are not available' do
      let(:query_counts) { DailyQueryStat::INSUFFICIENT_DATA }

      before do
        DailyQueryStat.stub(:most_popular_terms).with(site.name, Date.current, Date.current, 10).and_return query_counts
      end

      it 'should return nil' do
        dashboard.top_queries.should be_nil
      end
    end
  end

  describe "#top_urls" do
    context 'when top URLs are available' do
      let(:top_urls) { [['url1', 30], ['url2', 15]] }

      before do
        DailyClickStat.stub(:top_urls).with(site.name, Date.current, Date.current, 10).and_return top_urls
      end

      it 'should return an array of url/count pairs' do
        dashboard.top_urls.should == top_urls
      end
    end
  end

  describe "#trending_queries" do
    context 'when trending queries are available' do
      let(:trending_queries) { %w{jobs economy} }

      before do
        DailyQueryStat.stub(:trending_queries).with(site.name).and_return trending_queries
      end

      it 'should return an array of queries' do
        dashboard.trending_queries.should == trending_queries
      end
    end
  end

  describe "#low_ctr_queries" do
    context 'when low CTR queries are available' do
      let(:low_ctr_queries) { [['seldom', 5], ['never', 0]] }

      before do
        DailyQueryStat.stub(:low_ctr_queries).with(site.name).and_return low_ctr_queries
      end

      it 'should return an array of query/ctr pairs' do
        dashboard.low_ctr_queries.should == low_ctr_queries
      end
    end
  end

  describe '#no_results' do
    it 'should return most_popular_no_results_queries for today' do
      DailyQueryNoresultsStat.should_receive(:most_popular_no_results_queries).with(Date.current, Date.current, 10, site.name)
      dashboard.no_results
    end
  end

  describe "#trending_urls" do
    context 'when trending urls are available' do
      before do
        @trending_urls = %w{http://www.gov.gov/url1.html http://www.gov.gov/url2.html}
        @redis = double("Redis")
        Redis.stub(:new).and_return @redis
      end

      it 'should return an array of URLs' do
        @redis.should_receive(:smembers).with(['TrendingUrls', site.name].join(':')).and_return @trending_urls
        dashboard.trending_urls.should == @trending_urls
      end
    end
  end

  describe "#monthly_usage_chart" do
    context 'when several months of daily usage stats are present' do
      before do
        DailyUsageStat.create!(:day => Date.current.beginning_of_month, :total_queries => 10000, :affiliate => site.name)
        DailyUsageStat.create!(:day => 1.month.ago.beginning_of_month, :total_queries => 5000, :affiliate => site.name)
      end

      it 'should return a Google area chart' do
        dashboard.monthly_usage_chart.options['title'].should == 'Total Search Queries Over Time'
        dashboard.monthly_usage_chart.data_table.rows.size.should == 2
      end
    end

    context 'when fewer than several months of daily usage stats are present' do
      before do
        DailyUsageStat.delete_all
      end

      it 'should return nil' do
        dashboard.monthly_usage_chart.should be_nil
        DailyUsageStat.create!(:day => Date.current.beginning_of_month, :total_queries => 10000, :affiliate => site.name)
        dashboard.monthly_usage_chart.should be_nil
      end
    end
  end

  describe "#monthly_queries_to_date" do
    it 'should return query counts from DailyUsageStats table' do
      DailyUsageStat.should_receive(:monthly_totals).with(Date.current.year, Date.current.month, site.name)
      dashboard.monthly_queries_to_date
    end
  end

  describe "#monthly_clicks_to_date" do
    before do
      DailySearchModuleStat.create!(affiliate_name: site.name, day: Date.current, module_tag: 'VIDEO', vertical: 'recall', impressions: 3140, clicks: 314)
      DailySearchModuleStat.create!(affiliate_name: site.name, day: Date.current.beginning_of_month, module_tag: 'BWEB', vertical: 'web', impressions: 140, clicks: 14)
    end

    it 'should return click counts from DailySearchModuleStat table' do
      dashboard.monthly_clicks_to_date.should == 328
    end
  end

  context 'when target date is passed into initializer' do
    let(:target_date) { Date.parse('2013-04-28')}

    let(:yday_dashboard) { Dashboard.new(site, target_date) }

    it 'should use the date to compute most popular terms' do
      DailyQueryStat.should_receive(:most_popular_terms).with(site.name, target_date, target_date, 10)
      yday_dashboard.top_queries
    end

    it 'should use the date to compute most popular URLs' do
      DailyClickStat.should_receive(:top_urls).with(site.name, target_date, target_date, 10)
      yday_dashboard.top_urls
    end

    it 'should return most_popular_no_results_queries for the target date' do
      DailyQueryNoresultsStat.should_receive(:most_popular_no_results_queries).with(target_date, target_date, 10, site.name)
      yday_dashboard.no_results
    end
  end


end
