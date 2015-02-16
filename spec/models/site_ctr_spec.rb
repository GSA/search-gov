require 'spec_helper'

describe SiteCtr do
  fixtures :affiliates

  let(:site_ctr) { SiteCtr.new(7, 'BOOS') }

  describe "#site_ctrs" do
    context "when stats are available for the range" do
      let(:historical_ctr_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/historical_site_ctr.json")) }
      let(:ctr_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/site_ctr.json")) }

      before do
        ES::client_reader.should_receive(:search).with(hash_including(type: %w(search click))).and_return(historical_ctr_json_response, ctr_json_response)
      end

      it "should return collection of SiteCtrStat instances ordered by decr search+click count" do
        stats = site_ctr.site_ctrs
        stats.first.site_id.should == affiliates(:usagov_affiliate).id
        stats.first.display_name.should == affiliates(:usagov_affiliate).display_name
        stats.first.historical.impressions.should == 15101
        stats.first.historical.clicks.should == 185
        stats.first.recent.impressions.should == 5101
        stats.first.recent.clicks.should == 85

        stats.last.site_id.should == affiliates(:basic_affiliate).id
        stats.last.display_name.should == affiliates(:basic_affiliate).display_name
        stats.last.historical.impressions.should == 11
        stats.last.historical.clicks.should == 0
        stats.last.recent.impressions.should == 1
        stats.last.recent.clicks.should == 0
      end

    end

    context "when no stats are available for the daterange" do
      before do
        ES::client_reader.should_receive(:search).with(hash_including(type: %w(search click))).twice.and_return nil
      end

      it "should return an empty array" do
        stats = site_ctr.site_ctrs
        stats.should == []
      end
    end
  end

end
