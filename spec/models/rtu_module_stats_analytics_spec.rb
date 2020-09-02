require 'spec_helper'

describe RtuModuleStatsAnalytics do
  fixtures :search_modules

  let(:module_stats_analytics) { RtuModuleStatsAnalytics.new(Date.yesterday..Date.current, 'site name', true) }

  describe "#module_stats" do
    context "when stats are available for the range" do
      let(:mb_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/module_breakdown.json")) }
      let(:ms_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/module_sparklines.json")) }
      let(:os_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/overall_sparkline.json")) }

      before do
        expect(ES::ELK.client_reader).to receive(:search).
          and_return(mb_json_response,
                     ms_json_response,
                     os_json_response,
                     mb_json_response)
      end

      it "should return collection of structures including all verticals/affiliates, grouped by module, summed over the date range, ordered by descending impression count that respond to display_name, impressions, clicks, clickthru_ratio, average_clickthru_ratio, and historical_ctr" do
        stats = module_stats_analytics.module_stats

        expect(stats.first.display_name).to eq(search_modules(:bweb).display_name)
        expect(stats.first.impressions).to eq(97612)
        expect(stats.first.clicks).to eq(49436)
        expect(stats.first.clickthru_ratio).to be_within(0.001).of(50.645)
        expect(stats.first.average_clickthru_ratio).to be_within(0.001).of(50.645)
        expect(stats.first.historical_ctr.last).to be_within(0.001).of(48.739)

        expect(stats.last.display_name).to eq('Total')
        expect(stats.last.impressions).to eq(118631)
        expect(stats.last.clicks).to eq(53686)
        expect(stats.last.clickthru_ratio).to be_within(0.001).of(45.254)
        expect(stats.last.average_clickthru_ratio).to be_nil
        expect(stats.last.historical_ctr.last).to be_within(0.001).of(48.404)
      end

    end

    context "when no stats are available for the daterange" do

      it "should return an empty array" do
        stats = module_stats_analytics.module_stats
        expect(stats).to eq([])
      end
    end
  end

end
