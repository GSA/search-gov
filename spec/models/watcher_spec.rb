require 'spec_helper'


describe Watcher do
  before do
    WatcherObserver.any_instance.stub(:after_save)
    WatcherObserver.any_instance.stub(:after_destroy)
  end

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_format_of(:check_interval).with("1 day").with_message(/check_interval is invalid/) }
  it { should validate_format_of(:throttle_period).with("minute").with_message(/throttle_period is invalid/) }

end
