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
        ES::client_reader.stub(:search).and_return(mb_json_response, ms_json_response, os_json_response, mb_json_response)
      end

      it "should return collection of structures including all verticals/affiliates, grouped by module, summed over the date range, ordered by descending impression count that respond to display_name, impressions, clicks, clickthru_ratio, average_clickthru_ratio, and historical_ctr" do
        stats = module_stats_analytics.module_stats

        stats.first.display_name.should == search_modules(:bweb).display_name
        stats.first.impressions.should == 97612
        stats.first.clicks.should == 49436
        stats.first.clickthru_ratio.should be_within(0.001).of(50.645)
        stats.first.average_clickthru_ratio.should be_within(0.001).of(50.645)
        stats.first.historical_ctr.last.should be_within(0.001).of(48.739)

        stats.last.display_name.should == 'Total'
        stats.last.impressions.should == 118631
        stats.last.clicks.should == 53686
        stats.last.clickthru_ratio.should be_within(0.001).of(45.254)
        stats.last.average_clickthru_ratio.should be_nil
        stats.last.historical_ctr.last.should be_within(0.001).of(48.404)
      end

    end

    context "when no stats are available for the daterange" do

      it "should return an empty array" do
        stats = module_stats_analytics.module_stats
        stats.should == []
      end
    end
  end

end
