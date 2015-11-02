require 'spec_helper'

describe RtuMonthlyReport do
  fixtures :affiliates

  let(:site) { affiliates(:basic_affiliate) }
  let(:rtu_monthly_report) { RtuMonthlyReport.new(site, '2014','5', true) }

  describe "counts" do
    describe "#total_queries" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/count.json")) }

      before do
        ES::client_reader.stub(:count).and_return(json_response)
      end

      it 'should return RTU query counts for given month' do
        rtu_monthly_report.total_queries.should == 62330
      end
    end

    describe "#total_clicks" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/count.json")) }

      before do
        ES::client_reader.stub(:count).and_return(json_response)
      end

      it 'should return RTU click counts for given month' do
        rtu_monthly_report.total_clicks.should == 62330
      end
    end

    context 'when count is not available' do
      before do
        ES::client_reader.stub(:count).and_raise StandardError
      end

      it 'should return nil' do
        rtu_monthly_report.total_queries.should be_nil
        rtu_monthly_report.total_clicks.should be_nil
      end
    end

  end

  describe "#no_result_queries" do
    context 'when top no results queries are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_monthly_report/no_result_queries.json")) }
      let(:no_result_queries) { [['tsunade', 24], ['jiraiya', 22], ['orochimaru', 32]] }

      before do
        ES::client_reader.stub(:search).and_return json_response
      end

      it 'should return an array of query/count pairs' do
        no_results = json_response["aggregations"]["agg"]["buckets"].collect { |hash| [hash["key"], hash["doc_count"]] }
        rtu_monthly_report.no_result_queries.should == no_results
      end
    end
  end

  describe '#low_ctr_queries' do
    context 'low CTR queries are available' do
      let(:available_dates_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_monthly_report/available_dates.json")) }
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_monthly_report/low_ctr.json")) }
      let(:low_ctr_queries) { [["brandon colker", 0], ["address", 2], ["981", 12]] }

      before do
        ES::client_reader.stub(:search).and_return(available_dates_response, json_response)
      end

      it 'should return an array of query/CTR pairs with at least 20 searches and CTR below 20% for today' do
        rtu_monthly_report.low_ctr_queries.should == low_ctr_queries
      end
    end
  end

  describe "#search_module_stats" do
    let(:rtu_module_stats_analytics) { mock(RtuModuleStatsAnalytics, module_stats: "bunch of stats")}

    before do
      rangeof_date = rtu_monthly_report.picked_date..rtu_monthly_report.picked_date.end_of_month
      RtuModuleStatsAnalytics.should_receive(:new).with(rangeof_date, site.name, true).and_return rtu_module_stats_analytics
    end

    it 'should return the search module stats and sparklines' do
      rtu_monthly_report.search_module_stats.should == 'bunch of stats'
    end
  end

end
