require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Affiliate do
  fixtures :users, :affiliates
  before(:each) do
    @valid_attributes = {
      :name => "someaffiliate.gov",
      :domains => "someaffiliate.gov",
      :website => "http://www.someaffiliate.gov",
      :header => "<table><tr><td>html layout from 1998</td></tr></table>",
      :footer => "<center>gasp</center>",
      :user => users(:affiliate_manager)
    }
  end

  describe "Creating new instance of Affiliate" do
    should_validate_presence_of :name
    should_validate_uniqueness_of :name
    should_validate_length_of :name, :within=> (3..33)
    should_not_allow_values_for :name, "<IMG SRC=", "259771935505'", "spacey name"
    should_allow_values_for :name, "data.gov", "ct-new", "NewAff", "some_aff", "123"
    should_belong_to :user
    should_have_many :boosted_sites

    it "should create a new instance given valid attributes" do
      Affiliate.create!(@valid_attributes)
    end
  end
end
