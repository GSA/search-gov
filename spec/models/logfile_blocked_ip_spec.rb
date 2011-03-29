require "#{File.dirname(__FILE__)}/../spec_helper"
describe LogfileBlockedIp do
  fixtures :logfile_blocked_ips

  before do
    @valid_attributes = {:ip => "100.10.1.99"}
  end

  it "should create a new instance given valid attributes" do
    LogfileBlockedIp.create!(@valid_attributes)
  end

  should_validate_presence_of :ip
  should_validate_uniqueness_of :ip
end
