require 'spec_helper'

describe RtuMonthlyReport do
  fixtures :affiliates

  let(:site) { affiliates(:basic_affiliate) }
  let(:rtu_monthly_report) { RtuMonthlyReport.new(site, '2014','5', true) }
  let(:available_dates_response) do
    JSON.parse(read_fixture_file('/json/rtu_monthly_report/available_dates.json'))
  end

  describe "counts" do
    describe "#total_queries" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/count.json")) }

      before do
        allow(ES::ELK.client_reader).to receive(:count).and_return(json_response)
      end

      it 'should return RTU query counts for given month' do
        expect(rtu_monthly_report.total_queries).to eq(62330)
      end
    end

    describe "#total_clicks" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/count.json")) }

      before do
        allow(ES::ELK.client_reader).to receive(:count).and_return(json_response)
      end

      it 'should return RTU click counts for given month' do
        expect(rtu_monthly_report.total_clicks).to eq(62330)
      end
    end

    context 'when count is not available' do
      before do
        allow(ES::ELK.client_reader).to receive(:count).and_raise StandardError
      end

      it 'should return nil' do
        expect(rtu_monthly_report.total_queries).to be_nil
        expect(rtu_monthly_report.total_clicks).to be_nil
      end
    end

  end

  describe "#no_result_queries" do
    context 'when top no results queries are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_monthly_report/no_result_queries.json")) }
      let(:no_result_queries) { [['tsunade', 24], ['jiraiya', 22], ['orochimaru', 32]] }
      let(:query_args) do
        [
          site.name,
          'search',
          Date.new(2014,5,1),
          Date.new(2014,5,31),
          { field: 'params.query.raw', min_doc_count: 20 }
        ]
      end
      let(:query) { instance_double(DateRangeTopNMissingQuery, body: '') }

      before do
        expect(DateRangeTopNMissingQuery).
          to receive(:new).with(*query_args).and_return(query)
        allow(ES::ELK.client_reader).to receive(:search).
          and_return(available_dates_response, json_response)
      end

      it 'should return an array of query/count pairs' do
        no_results = json_response["aggregations"]["agg"]["buckets"].collect { |hash| [hash["key"], hash["doc_count"]] }
        expect(rtu_monthly_report.no_result_queries).to eq(no_results)
      end
    end
  end

  describe '#low_ctr_queries' do
    context 'low CTR queries are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_monthly_report/low_ctr.json")) }
      let(:low_ctr_queries) { [["brandon colker", 0], ["address", 2], ["981", 12]] }

      before do
        allow(ES::ELK.client_reader).to receive(:search).and_return(available_dates_response, json_response)
      end

      it 'should return an array of query/CTR pairs with at least 20 searches and CTR below 20% for today' do
        expect(rtu_monthly_report.low_ctr_queries).to eq(low_ctr_queries)
      end
    end
  end

  describe "#search_module_stats" do
    let(:rtu_module_stats_analytics) { double(RtuModuleStatsAnalytics, module_stats: "bunch of stats")}

    before do
      rangeof_date = rtu_monthly_report.picked_date..rtu_monthly_report.picked_date.end_of_month
      expect(RtuModuleStatsAnalytics).to receive(:new).with(rangeof_date, site.name, true).and_return rtu_module_stats_analytics
    end

    it 'should return the search module stats and sparklines' do
      expect(rtu_monthly_report.search_module_stats).to eq('bunch of stats')
    end
  end

end
