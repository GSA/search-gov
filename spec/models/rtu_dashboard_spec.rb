require 'spec_helper'

describe RtuDashboard do
  fixtures :affiliates

  let(:site) { affiliates(:basic_affiliate) }
  let(:dashboard) { RtuDashboard.new(site, Date.current, true) }

  describe "#top_queries" do
    context 'when top queries are available' do
      before do
        allow(RtuQueryRawHumanArray).to receive(:new).and_return double(RtuQueryRawHumanArray, top_queries: [['query5', 54, 53], ['query6', 55, 43], ['query4', 53, 42]])
      end

      it 'should return an array of [query, total, human] sorted by desc human' do
        expect(dashboard.top_queries).to match_array([['query5', 54, 53], ['query6', 55, 43], ['query4', 53, 42]])
      end
    end

    context 'when top queries are not available' do
      before do
        allow(ES::ELK.client_reader).to receive(:search).and_raise StandardError
      end

      it 'should return nil' do
        expect(dashboard.top_queries).to be_nil
      end
    end
  end

  describe "#no_results" do
    context 'when top no results queries are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_queries.json")) }

      before do
        expect(TopNMissingQuery).to receive(:new).at_least(:once).
          with(site.name, 'search', field: 'params.query.raw', min_doc_count: 10).
          and_call_original
        allow(ES::ELK.client_reader).to receive(:search).and_return json_response
      end

      it 'should return an array of QueryCount instances' do
        no_results = json_response["aggregations"]["agg"]["buckets"].collect { |hash| QueryCount.new(hash["key"], hash["doc_count"]) }
        expect(dashboard.no_results.size).to eq(no_results.size)
        dashboard.no_results.each_with_index do |tq, idx|
          expect(tq.query).to eq(no_results[idx].query)
          expect(tq.times).to eq(no_results[idx].times)
        end
      end
    end

  end

  describe "#top_urls" do
    context 'when top URLs are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_urls.json")) }

      before do
        allow(ES::ELK.client_reader).to receive(:search).and_return json_response
      end

      it "searches for the affiliate's top N URLs" do
        expect(TopNQuery).to receive(:new).
          with(site.name, 'click', field: 'params.url').
          and_call_original
        dashboard.top_urls
      end

      it 'should return an array of url/count pairs' do
        top_urls = Hash[json_response["aggregations"]["agg"]["buckets"].collect { |hash| [hash["key"], hash["doc_count"]] }]
        expect(dashboard.top_urls).to eq(top_urls)
      end
    end

    context 'when something goes wrong' do
      before do
        allow(ES::ELK.client_reader).to receive(:search).
          and_raise(StandardError, 'failure')
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).
          with(/Error querying top_n data: failure/)
        dashboard.top_urls
      end
    end
  end

  describe "#trending_queries" do
    context 'when trending queries are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/trending_queries.json")) }

      before do
        allow(ES::ELK.client_reader).to receive(:search).and_return json_response
      end

      it 'should return an array of trending/significant queries coming from at least 10 IPs' do
        expect(dashboard.trending_queries).to eq(["memorial day", "petitions"])
      end
    end
  end

  describe "#low_ctr_queries" do
    context 'when low CTR queries are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/low_ctr.json")) }
      let(:low_ctr_queries) { [["brandon colker", 0], ["address", 2], ["981", 12]] }

      before do
        allow(ES::ELK.client_reader).to receive(:search).and_return(json_response)
      end

      it 'should return an array of query/CTR pairs with at least 20 searches and CTR below 20% for today' do
        expect(dashboard.low_ctr_queries).to eq(low_ctr_queries)
      end
    end

    context 'low CTR queries are not available' do
      before do
        allow(ES::ELK.client_reader).to receive(:search).and_raise
      end

      it 'should return an empty array' do
        expect(dashboard.low_ctr_queries).to eq([])
      end
    end
  end

  describe "#monthly_usage_chart" do
    let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/month_histogram.json")) }
    let(:monthly_histogram_query) do
      instance_double(MonthlyHistogramQuery, body: 'monthly_histogram_query')
    end

    before do
      allow(MonthlyHistogramQuery).to receive(:new).
        with(site.name).and_return(monthly_histogram_query)
      allow(ES::ELK.client_reader).to receive(:search).
        with(hash_including(body: 'monthly_histogram_query')).
        and_return(json_response)
    end

    it 'creates a Google chart' do
      expect(dashboard.monthly_usage_chart).to be_an_instance_of(GoogleVisualr::Interactive::AreaChart)
    end
  end

  describe "counts" do
    describe "#monthly_queries_to_date" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/count.json")) }

      before do
        allow(ES::ELK.client_reader).to receive(:count).and_return(json_response)
      end

      it 'should return RTU query counts for current month' do
        expect(dashboard.monthly_queries_to_date).to eq(62330)
      end
    end

    describe "#monthly_clicks_to_date" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/count.json")) }

      before do
        allow(ES::ELK.client_reader).to receive(:count).and_return(json_response)
      end

      it 'should return RTU click counts for current month' do
        expect(dashboard.monthly_clicks_to_date).to eq(62330)
      end
    end

    context 'when count is not available' do
      before do
        allow(ES::ELK.client_reader).to receive(:count).and_raise StandardError
      end

      it 'should return nil' do
        expect(dashboard.monthly_clicks_to_date).to be_nil
        expect(dashboard.monthly_queries_to_date).to be_nil
      end
    end

  end
end
