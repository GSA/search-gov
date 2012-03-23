require 'spec/spec_helper'

describe QueryCount do
  it "should initialize a new instance given valid attributes" do
    qc = QueryCount.new("foo", "30")
    qc.query.should == "foo"
    qc.times.should == 30
  end
end
