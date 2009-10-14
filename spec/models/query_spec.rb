require "#{File.dirname(__FILE__)}/../spec_helper"
describe Query do
  before(:each) do
    @valid_attributes = {
      :query => "government",
      :ipaddr => "123.456.7.89",
      :affiliate => "usasearch.gov",
      :timestamp => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    Query.create!(@valid_attributes)
  end

  should_validate_presence_of :ipaddr
  should_validate_presence_of :affiliate
  should_validate_presence_of :timestamp

end
