require 'spec_helper'
describe LogfileWhitelistedClassC do
  fixtures :logfile_whitelisted_class_cs

  before do
    @valid_attributes = {:classc => "20.30.40"}
  end

  it "should create a new instance given valid attributes" do
    LogfileWhitelistedClassC.create!(@valid_attributes)
  end

  it { should validate_presence_of :classc }
  it { should validate_uniqueness_of :classc }
end
