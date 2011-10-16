require 'spec/spec_helper'

describe QueryCount do
  it "should initialize a new instance given valid attributes" do
    qc = QueryCount.new("foo", "30", true)
    qc.query.should == "foo"
    qc.times.should == 30
    qc.is_grouped.should be_true
  end

  context "when is_grouped is not specified" do
    it "should default to false (not grouped)" do
      QueryCount.new("foo", 30).is_grouped?.should be_false
    end
  end

end
