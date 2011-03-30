require "#{File.dirname(__FILE__)}/../spec_helper"
describe LogfileBlockedQuery do
  fixtures :logfile_blocked_queries

  before do
    @valid_attributes = {:query => "block this"}
  end

  it "should create a new instance given valid attributes" do
    LogfileBlockedQuery.create!(@valid_attributes)
  end

  it { should validate_presence_of :query }
  it { should validate_uniqueness_of :query }
end
