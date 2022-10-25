# frozen_string_literal: true

describe LowQueryCtrWatcher do
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:user) { affiliate.users.first }
  let(:watcher_args) do
    {
      search_click_total: 101,
      low_ctr_threshold: 15.5,
      affiliate_id: affiliate.id,
      user_id: user.id,
      time_window: '1w',
      query_blocklist: 'foo, bar, another one',
      check_interval: '1m',
      throttle_period: '24h',
      name: 'low CTR'
    }
  end
  let(:expected_body) do
    JSON.parse(read_fixture_file('/json/watcher/low_query_ctr_watcher_body.json')).to_json
  end
  subject(:watcher) { described_class.new(watcher_args) }

  it { is_expected.to validate_numericality_of(:search_click_total).only_integer }
  it { is_expected.to validate_numericality_of(:low_ctr_threshold) }

  describe '.conditions' do
    subject(:conditions) { watcher.conditions }

    it { is_expected.to eq({ low_ctr_threshold: 15.5, search_click_total: 101 }) }
  end

  describe 'humanized_alert_threshold' do
    subject(:watcher) { described_class.new(search_click_total: 101, low_ctr_threshold: 15.5 ) }
    it 'returns a human-readable version of the alert threshold(s)' do
      expect(watcher.humanized_alert_threshold).to eq('15.5% CTR on 101 Queries & Clicks')
    end
  end

  describe '#label' do
    subject(:label) { watcher.label }

    it { is_expected.to eq('Low Query Click-Through Rate (CTR)') }
  end

  it_behaves_like 'a watcher'
end
