require 'spec_helper'

describe QueryCtr do

  let(:query_ctr) { QueryCtr.new(7, 'BOOS', 'usagov') }

  describe "#query_ctrs" do
    context "when stats are available for the range" do
      let(:historical_query_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/historical_query_ctr.json")) }
      let(:query_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/rtu_queries_request.json")) }

      before do
        ES::client_reader.should_receive(:search).with(hash_including(type: %w(search click))).and_return(historical_query_json_response, query_json_response)
      end

      it "should return collection of QueryCtrStat instances ordered by decr search+click count" do
        stats = query_ctr.query_ctrs
        stats.first.query.should == 'petition for marine held in mexico'
        stats.first.historical.impressions.should == 17
        stats.first.historical.clicks.should == 12
        stats.first.recent.impressions.should == 7
        stats.first.recent.clicks.should == 2

        stats.last.query.should == 'petition for marine jailed in mexico'
        stats.last.historical.impressions.should == 0
        stats.last.historical.clicks.should == 11
        stats.last.recent.impressions.should == 0
        stats.last.recent.clicks.should == 1
      end

    end

    context "when stats are available for the historical range but not for the current day" do
      let(:historical_query_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/historical_query_ctr.json")) }
      let(:query_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/recent_ctr_empty.json")) }

      before do
        ES::client_reader.should_receive(:search).with(hash_including(type: %w(search click))).and_return(historical_query_json_response, query_json_response)
      end

      it "should return collection of QueryCtrStat instances ordered by decr search+click count" do
        stats = query_ctr.query_ctrs
        stats.first.query.should == 'petition for marine held in mexico'
        stats.first.historical.impressions.should == 17
        stats.first.historical.clicks.should == 12
        stats.first.recent.impressions.should == 0
        stats.first.recent.clicks.should == 0

        stats.last.query.should == 'petition for marine jailed in mexico'
        stats.last.historical.impressions.should == 0
        stats.last.historical.clicks.should == 11
        stats.last.recent.impressions.should == 0
        stats.last.recent.clicks.should == 0
      end

    end

    context "when no stats are available for the daterange" do
      before do
        ES::client_reader.should_receive(:search).with(hash_including(type: %w(search click))).twice.and_return nil
      end

      it "should return an empty array" do
        stats = query_ctr.query_ctrs
        stats.should == []
      end
    end
  end

end
