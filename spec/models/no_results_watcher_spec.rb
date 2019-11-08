require 'spec_helper'

describe NoResultsWatcher do
  fixtures :affiliates, :users, :memberships
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:user) { affiliate.users.first }

  it { is_expected.to validate_numericality_of(:distinct_user_total).only_integer }

  describe "humanized_alert_threshold" do
    subject(:watcher) { described_class.new(distinct_user_total: 34) }
    it "returns a human-readable version of the alert threshold(s)" do
      expect(watcher.humanized_alert_threshold).to eq("34 Queries")
    end
  end

  describe "body" do
    let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/watcher/no_results_watcher_body.json")).to_json }

    subject(:watcher) { described_class.new(distinct_user_total: 34, affiliate_id: affiliate.id, user_id: user.id,
                                            time_window: '1w', query_blocklist: "foo, bar, another one",
                                            check_interval: '1m', throttle_period: '24h', name: "no rez") }

    # SRCH-1038
    xit "returns a JSON structure representing an Elasticsearch Watcher body" do
      expect(watcher.body).to eq(json_response)
    end
  end
end
