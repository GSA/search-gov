require 'spec_helper'
describe LogfileBlockedRegexp do
  fixtures :logfile_blocked_regexps

  before do
    @valid_attributes = {:regexp => "space&sitelimit=science."}
  end

  it "should create a new instance given valid attributes" do
    LogfileBlockedRegexp.create!(@valid_attributes)
  end

  it { should validate_presence_of :regexp }
  it { should validate_uniqueness_of :regexp }
end
