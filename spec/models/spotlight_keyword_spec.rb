require "#{File.dirname(__FILE__)}/../spec_helper"

describe SpotlightKeyword do
  fixtures :spotlights, :spotlight_keywords

  before(:each) do
    @valid_attributes = {
      :name => "some keyword about time",
      :spotlight => spotlights(:time)
    }
  end

  describe "Creating new instance" do
    should_validate_presence_of :name
    should_validate_uniqueness_of :name
    should_belong_to :spotlight

    it "should create a new instance given valid attributes" do
      SpotlightKeyword.create!(@valid_attributes)
    end
  end
end
