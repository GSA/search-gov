require "#{File.dirname(__FILE__)}/../spec_helper"
describe LogfileBlockedRegexp do
  fixtures :logfile_blocked_regexps

  before do
    @valid_attributes = {:regexp => "space&sitelimit=science."}
  end

  it "should create a new instance given valid attributes" do
    LogfileBlockedRegexp.create!(@valid_attributes)
  end

  should_validate_presence_of :regexp
  should_validate_uniqueness_of :regexp
end
