require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Affiliate do
  fixtures :users, :affiliates
  before(:each) do
    @valid_attributes = {
      :name => "someaffiliate.gov",
      :header => "<table><tr><td>html layout from 1998</td></tr></table>",
      :footer => "<center>gasp</center>",
      :user => users(:affiliate_manager)
    }
  end

  describe "Creating new instance of Affiliate" do
    should_validate_presence_of :name
    should_validate_uniqueness_of :name
    should_belong_to :user
    should_have_many :boosted_sites

    it "should create a new instance given valid attributes" do
      Affiliate.create!(@valid_attributes)
    end
  end
end
