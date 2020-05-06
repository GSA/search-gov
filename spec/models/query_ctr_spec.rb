require 'spec_helper'

describe QueryCtr do

  let(:query_ctr) { QueryCtr.new(7, 'BOOS', 'usagov') }

  describe "#query_ctrs" do
    context "when stats are available for the range" do
      let(:historical_query_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/historical_query_ctr.json")) }
      let(:query_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/rtu_queries_request.json")) }

      before do
        expect(ES::ELK.client_reader).to receive(:search).
          and_return(historical_query_json_response, query_json_response)
      end

      it "should return collection of QueryCtrStat instances ordered by decr search+click count" do
        stats = query_ctr.query_ctrs
        expect(stats.first.query).to eq('petition for marine held in mexico')
        expect(stats.first.historical.impressions).to eq(17)
        expect(stats.first.historical.clicks).to eq(12)
        expect(stats.first.recent.impressions).to eq(7)
        expect(stats.first.recent.clicks).to eq(2)

        expect(stats.last.query).to eq('petition for marine jailed in mexico')
        expect(stats.last.historical.impressions).to eq(0)
        expect(stats.last.historical.clicks).to eq(11)
        expect(stats.last.recent.impressions).to eq(0)
        expect(stats.last.recent.clicks).to eq(1)
      end

    end

    context "when stats are available for the historical range but not for the current day" do
      let(:historical_query_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/historical_query_ctr.json")) }
      let(:query_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/recent_ctr_empty.json")) }

      before do
        expect(ES::ELK.client_reader).to receive(:search).
          and_return(historical_query_json_response, query_json_response)
      end

      it "should return collection of QueryCtrStat instances ordered by decr search+click count" do
        stats = query_ctr.query_ctrs
        expect(stats.first.query).to eq('petition for marine held in mexico')
        expect(stats.first.historical.impressions).to eq(17)
        expect(stats.first.historical.clicks).to eq(12)
        expect(stats.first.recent.impressions).to eq(0)
        expect(stats.first.recent.clicks).to eq(0)

        expect(stats.last.query).to eq('petition for marine jailed in mexico')
        expect(stats.last.historical.impressions).to eq(0)
        expect(stats.last.historical.clicks).to eq(11)
        expect(stats.last.recent.impressions).to eq(0)
        expect(stats.last.recent.clicks).to eq(0)
      end

    end

    context "when no stats are available for the daterange" do
      before do
        expect(ES::ELK.client_reader).to receive(:search).twice.and_return nil
      end

      it "should return an empty array" do
        stats = query_ctr.query_ctrs
        expect(stats).to eq([])
      end
    end
  end

end
