require 'spec_helper'

describe LowQueryCtrWatcher do
  fixtures :affiliates, :users, :memberships
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:user) { affiliate.users.first }

  it { is_expected.to validate_numericality_of(:search_click_total).only_integer }
  it { is_expected.to validate_numericality_of(:low_ctr_threshold) }

  describe "humanized_alert_threshold" do
    subject(:watcher) { described_class.new(search_click_total: 101, low_ctr_threshold: 15.5 ) }
    it "returns a human-readable version of the alert threshold(s)" do
      expect(watcher.humanized_alert_threshold).to eq("15.5% CTR on 101 Queries & Clicks")
    end
  end

  describe "body" do
    let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/watcher/low_query_ctr_watcher_body.json")).to_json }

    subject(:watcher) { described_class.new(search_click_total: 101, low_ctr_threshold: 15.5, affiliate_id: affiliate.id,
                                            user_id: user.id, time_window: '1w', query_blocklist: "foo, bar, another one",
                                            check_interval: '1m', throttle_period: '24h', name: "low CTR") }

    it "returns a JSON structure representing an Elasticsearch Watcher body" do
      expect(watcher.body).to eq(json_response)
    end
  end
end
