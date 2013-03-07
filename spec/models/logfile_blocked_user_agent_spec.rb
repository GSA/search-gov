require 'spec_helper'
describe LogfileBlockedUserAgent do
  fixtures :logfile_blocked_user_agents

  before do
    @valid_attributes = {:agent => "spammy"}
  end

  it "should create a new instance given valid attributes" do
    LogfileBlockedUserAgent.create!(@valid_attributes)
  end

  it { should validate_presence_of :agent }
  it { should validate_uniqueness_of(:agent).case_insensitive }
end