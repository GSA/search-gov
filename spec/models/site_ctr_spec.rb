require 'spec_helper'

describe SiteCtr do
  fixtures :affiliates

  let(:site_ctr) { SiteCtr.new(7, 'BOOS') }

  describe "#site_ctrs" do
    context "when stats are available for the range" do
      let(:historical_ctr_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/historical_site_ctr.json")) }
      let(:ctr_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/site_ctr.json")) }

      before do
        expect(ES::ELK.client_reader).to receive(:search).
          and_return(historical_ctr_json_response, ctr_json_response)
      end

      it "should return collection of SiteCtrStat instances ordered by decr search+click count" do
        stats = site_ctr.site_ctrs
        expect(stats.first.site_name).to eq(affiliates(:usagov_affiliate).name)
        expect(stats.first.display_name).to eq(affiliates(:usagov_affiliate).display_name)
        expect(stats.first.historical.impressions).to eq(15101)
        expect(stats.first.historical.clicks).to eq(185)
        expect(stats.first.recent.impressions).to eq(5101)
        expect(stats.first.recent.clicks).to eq(85)

        expect(stats.last.site_name).to eq(affiliates(:basic_affiliate).name)
        expect(stats.last.display_name).to eq(affiliates(:basic_affiliate).display_name)
        expect(stats.last.historical.impressions).to eq(11)
        expect(stats.last.historical.clicks).to eq(0)
        expect(stats.last.recent.impressions).to eq(1)
        expect(stats.last.recent.clicks).to eq(0)
      end

    end

    context "when no stats are available for the daterange" do
      before do
        expect(ES::ELK.client_reader).to receive(:search).twice.and_return nil
      end

      it "should return an empty array" do
        stats = site_ctr.site_ctrs
        expect(stats).to eq([])
      end
    end
  end

end
