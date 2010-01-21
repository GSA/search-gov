require "#{File.dirname(__FILE__)}/../spec_helper"
describe Click do
  before(:each) do
    @valid_attributes = {
      :query => "barack obama",
      :queried_at => Time.now,
      :url => 'http://www.whitehouse.gov/',
      :serp_position => 1,
      :property_used => nil
    }
  end

  it "should create a new instance given valid attributes" do
    Click.create!(@valid_attributes)
  end

  should_validate_presence_of :queried_at
  should_validate_presence_of :url
end
