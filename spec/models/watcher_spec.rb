require 'spec_helper'

describe Watcher do
  before do
    WatcherObserver.any_instance.stub(:after_save)
    WatcherObserver.any_instance.stub(:after_destroy)
  end

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).case_insensitive }
  %i(check_interval throttle_period time_window).each do |field|
    ["5wk", "1y", "week", "3 h"].each do |value|
      it { should_not allow_value(value).for(field) }
    end
  end
  it { should ensure_length_of(:query_blocklist).is_at_most(150) }
  ["5w", "30d", "800h"].each do |value|
    it { should_not allow_value(value).for(:time_window) }
  end

end
