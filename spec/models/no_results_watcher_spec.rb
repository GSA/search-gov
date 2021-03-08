require 'spec_helper'

describe NoResultsWatcher do
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:user) { affiliate.users.first }
  let(:watcher_args) do
    {
      distinct_user_total: 34,
      affiliate_id: affiliate.id,
      user_id: user.id,
      time_window: '1w',
      query_blocklist: 'foo, bar, another one',
      check_interval: '1m',
      throttle_period: '24h',
      name: 'no rez'
    }
  end
  let(:expected_body) do
    JSON.parse(read_fixture_file('/json/watcher/no_results_watcher_body.json')).to_json
  end

  subject(:watcher) { described_class.new(watcher_args) }

  it { is_expected.to validate_numericality_of(:distinct_user_total).only_integer }

  describe 'humanized_alert_threshold' do
    subject(:watcher) { described_class.new(distinct_user_total: 34) }
    it 'returns a human-readable version of the alert threshold(s)' do
      expect(watcher.humanized_alert_threshold).to eq('34 Queries')
    end
  end

  describe '#label' do
    subject(:label) { watcher.label }

    it { is_expected.to eq('No Results') }
  end

  it_behaves_like 'a watcher'
end
