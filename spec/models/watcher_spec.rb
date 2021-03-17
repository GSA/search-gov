require 'spec_helper'

describe Watcher do
  before do
    allow_any_instance_of(WatcherObserver).to receive(:after_save)
    allow_any_instance_of(WatcherObserver).to receive(:after_destroy)
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  %i(check_interval throttle_period time_window).each do |field|
    ['5wk', '1y', 'week', '3 h'].each do |value|
      it { is_expected.not_to allow_value(value).for(field) }
    end
  end
  it { is_expected.to validate_length_of(:query_blocklist).is_at_most(150) }
  ['5w', '30d', '800h'].each do |value|
    it { is_expected.not_to allow_value(value).for(:time_window) }
  end

end
