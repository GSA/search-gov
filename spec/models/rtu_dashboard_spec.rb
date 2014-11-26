require 'spec_helper'

describe RtuDashboard do
  fixtures :affiliates

  let(:site) { affiliates(:basic_affiliate) }
  let(:dashboard) { RtuDashboard.new(site, Date.current, true) }

  describe "#top_queries" do
    context 'when top queries are available' do
      before do
        RtuQueryRawHumanArray.stub(:new).and_return mock(RtuQueryRawHumanArray, top_queries: [['query5', 54, 53], ['query6', 55, 43], ['query4', 53, 42]])
      end

      it 'should return an array of [query, total, human] sorted by desc human' do
        dashboard.top_queries.should match_array([['query5', 54, 53], ['query6', 55, 43], ['query4', 53, 42]])
      end
    end

    context 'when top queries are not available' do
      before do
        ES::client_reader.stub(:search).and_raise StandardError
      end

      it 'should return nil' do
        dashboard.top_queries.should be_nil
      end
    end
  end

  describe "#no_results" do
    context 'when top no results queries are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_queries.json")) }

      before do
        ES::client_reader.stub(:search).and_return json_response
      end

      it 'should return an array of QueryCount instances' do
        no_results = json_response["aggregations"]["agg"]["buckets"].collect { |hash| QueryCount.new(hash["key"], hash["doc_count"]) }
        dashboard.no_results.size.should == no_results.size
        dashboard.no_results.each_with_index do |tq, idx|
          tq.query.should == no_results[idx].query
          tq.times.should == no_results[idx].times
        end
      end
    end

  end

  describe "#top_urls" do
    context 'when top URLs are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_urls.json")) }

      before do
        ES::client_reader.stub(:search).and_return json_response
      end

      it 'should return an array of url/count pairs' do
        top_urls = Hash[json_response["aggregations"]["agg"]["buckets"].collect { |hash| [hash["key"], hash["doc_count"]] }]
        dashboard.top_urls.should == top_urls
      end
    end
  end

  describe "#trending_queries" do
    context 'when trending queries are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/trending_queries.json")) }

      before do
        ES::client_reader.stub(:search).and_return json_response
      end

      it 'should return an array of trending/significant queries coming from at least 10 IPs' do
        dashboard.trending_queries.should == ["memorial day", "petitions"]
      end
    end
  end

  describe "#low_ctr_queries" do
    context 'when low CTR queries are available' do
      let(:query_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/low_ctr_queries.json")) }
      let(:click_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/low_ctr_clicks.json")) }
      let(:low_ctr_queries) { [["search", 0], ["china", 11], ["981", 12]] }

      before do
        ES::client_reader.stub(:search).and_return(query_json_response, click_json_response)
      end

      it 'should return an array of query/CTR pairs with at least 20 searches and CTR below 20% for today' do
        dashboard.low_ctr_queries.should == low_ctr_queries
      end
    end
  end

  describe "counts" do
    describe "#monthly_queries_to_date" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/count.json")) }

      before do
        ES::client_reader.stub(:count).and_return(json_response)
      end

      it 'should return RTU query counts for current month' do
        dashboard.monthly_queries_to_date.should == 62330
      end
    end

    describe "#monthly_clicks_to_date" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/count.json")) }

      before do
        ES::client_reader.stub(:count).and_return(json_response)
      end

      it 'should return RTU click counts for current month' do
        dashboard.monthly_clicks_to_date.should == 62330
      end
    end

    context 'when count is not available' do
      before do
        ES::client_reader.stub(:count).and_raise StandardError
      end

      it 'should return nil' do
        dashboard.monthly_clicks_to_date.should be_nil
        dashboard.monthly_queries_to_date.should be_nil
      end
    end

  end

  describe "#monthly_queries_histogram" do
    context 'when data exists prior to June 2014' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/month_histogram.json")) }

      before do
        ES::client_reader.stub(:search).and_return json_response
        DailyUsageStat.create!(:day => Date.parse('2014-04-01'), :total_queries => 110000, :affiliate => site.name)
        DailyUsageStat.create!(:day => Date.parse('2014-05-01'), :total_queries => 320000, :affiliate => site.name)
      end

      it 'should incorporate that data with the ES data since June 1, 2014' do
        dashboard.monthly_queries_histogram.should == [["2014-04", 110000], ["2014-05", 320000], ["2014-06", 383828], ["2014-07", 123456]]
      end
    end
  end

  describe "#monthly_usage_chart" do
    context 'when data exists prior to June 2014' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/month_histogram.json")) }

      before do
        ES::client_reader.stub(:search).and_return json_response
        DailyUsageStat.create!(:day => Date.parse('2014-04-01'), :total_queries => 110000, :affiliate => site.name)
        DailyUsageStat.create!(:day => Date.parse('2014-05-01'), :total_queries => 320000, :affiliate => site.name)
      end

      it 'should incorporate that data with the ES data since June 1, 2014 for the chart' do
        dashboard.monthly_usage_chart.should be_an_instance_of(GoogleVisualr::Interactive::AreaChart)
      end
    end
  end

end
