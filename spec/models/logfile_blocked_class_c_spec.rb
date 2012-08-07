require 'spec_helper'
describe LogfileBlockedClassC do
  fixtures :logfile_blocked_class_cs

  before do
    @valid_attributes = {:classc => "20.30.40"}
  end

  it "should create a new instance given valid attributes" do
    LogfileBlockedClassC.create!(@valid_attributes)
  end

  it { should validate_presence_of :classc }
  it { should validate_uniqueness_of :classc }
end
