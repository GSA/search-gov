require 'spec_helper'

describe RtuDashboard do
  fixtures :affiliates

  let(:site) { affiliates(:basic_affiliate) }
  let(:dashboard) { RtuDashboard.new(site) }

  describe "#top_queries" do
    context 'when top queries are available' do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_queries.json")) }

      before do
        ES::client_reader.stub(:search).and_return json_response
      end

      it 'should return an array of QueryCount instances' do
        top_queries = json_response["aggregations"]["agg"]["buckets"].collect { |hash| QueryCount.new(hash["key"], hash["doc_count"]) }
        dashboard.top_queries.size.should == top_queries.size
        dashboard.top_queries.each_with_index do |tq, idx|
          tq.query.should == top_queries[idx].query
          tq.times.should == top_queries[idx].times
        end
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


end
