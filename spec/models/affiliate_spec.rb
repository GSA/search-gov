require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Affiliate do
  fixtures :affiliates

  before(:each) do
    @valid_attributes = {
      :name => "someaffiliate.gov",
      :header => "<table><tr><td>html layout from 1998</td></tr></table>",
      :footer => "<center>gasp</center>"
    }
  end

  should_validate_presence_of :name
  should_validate_uniqueness_of :name

  it "should create a new instance given valid attributes" do
    Affiliate.create!(@valid_attributes)
  end
end
