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

  describe "#domain_list" do
    it "should return site restriction list for valid list" do
      affiliate = Affiliate.new(:domains => %w(foo.com bar.com blat.com).join("\n"))
      affiliate.domain_list.should == "site:foo.com OR site:bar.com OR site:blat.com"
    end

    it "should return an empty string for blank or nil domains field" do
      affiliate = Affiliate.new(:domains => nil)
      affiliate.domain_list.should == ""
      affiliate = Affiliate.new(:domains => "")
      affiliate.domain_list.should == ""
    end
  end
end
