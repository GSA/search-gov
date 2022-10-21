# frozen_string_literal: true

describe Watcher do
  let(:watcher) { described_class.new }

  before do
    allow_any_instance_of(WatcherObserver).to receive(:after_save)
    allow_any_instance_of(WatcherObserver).to receive(:after_destroy)
  end

  describe 'schema' do
    it { is_expected.to have_db_column(:safe_conditions).of_type(:json) }
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  %i[check_interval throttle_period time_window].each do |field|
    ['5wk', '1y', 'week', '3 h'].each do |value|
      it { is_expected.not_to allow_value(value).for(field) }
    end
  end
  it { is_expected.to validate_length_of(:query_blocklist).is_at_most(150) }

  %w[5w 30d 800h].each do |value|
    it { is_expected.not_to allow_value(value).for(:time_window) }
  end

  describe '.conditions' do
    subject(:conditions) { watcher.conditions }

    it { is_expected.to be_a Hash }
  end
end
