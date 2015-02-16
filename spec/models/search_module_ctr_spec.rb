require 'spec_helper'

describe SearchModuleCtr do
  fixtures :search_modules

  let(:search_module_ctr) { SearchModuleCtr.new(7) }

  describe "#search_module_ctrs" do
    context "when stats are available for the range" do
      let(:historical_mb_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/historical_module_breakdown.json")) }
      let(:mb_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/module_breakdown.json")) }

      before do
        ES::client_reader.should_receive(:search).with(hash_including(type: %w(search click))).and_return(historical_mb_json_response, mb_json_response)
      end

      it "should return collection of SearchModuleCtrStat instances ordered by decr search+click count" do
        stats = search_module_ctr.search_module_ctrs
        stats.first.name.should == search_modules(:bweb).display_name
        stats.first.tag.should == search_modules(:bweb).tag
        stats.first.historical.impressions.should == 197612
        stats.first.historical.clicks.should == 149436
        stats.first.recent.impressions.should == 97612
        stats.first.recent.clicks.should == 49436

        stats.last.name.should == search_modules(:bbg).display_name
        stats.last.tag.should == search_modules(:bbg).tag
        stats.last.historical.impressions.should == 19251
        stats.last.historical.clicks.should == 11391
        stats.last.recent.impressions.should == 9251
        stats.last.recent.clicks.should == 1391
      end

    end

    context "when no stats are available for the daterange" do
      before do
        ES::client_reader.should_receive(:search).with(hash_including(type: %w(search click))).twice.and_return nil
      end

      it "should return an empty array" do
        stats = search_module_ctr.search_module_ctrs
        stats.should == []
      end
    end
  end

end
