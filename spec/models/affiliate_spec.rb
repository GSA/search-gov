require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Affiliate do
  fixtures :users, :affiliates, :affiliate_templates

  before(:each) do
    @valid_attributes = {
      :name => "someaffiliate.gov",
      :domains => "someaffiliate.gov",
      :website => "http://www.someaffiliate.gov",
      :header => "<table><tr><td>html layout from 1998</td></tr></table>",
      :footer => "<center>gasp</center>",
      :owner => users(:affiliate_manager),
    }
  end

  describe "Creating new instance of Affiliate" do
    should_validate_presence_of :name
    should_validate_uniqueness_of :name
    should_validate_length_of :name, :within=> (3..33)
    should_not_allow_values_for :name, "<IMG SRC=", "259771935505'", "spacey name"
    should_allow_values_for :name, "data.gov", "ct-new", "NewAff", "some_aff", "123"
    should_belong_to :owner
    should_have_and_belong_to_many :users
    should_have_many :boosted_sites
    should_have_many :sayt_suggestions
    should_have_many :calais_related_searches

    it "should create a new instance given valid attributes" do
      Affiliate.create!(@valid_attributes)
    end

    it "should have SAYT disabled by default" do
      Affiliate.create!(@valid_attributes).is_sayt_enabled.should be_false
    end

    it "should have Affiliate-specific SAYT suggestions disabled by default" do
      Affiliate.create!(@valid_attributes).is_affiliate_suggestions_enabled.should be_false
    end
  end

  describe "#template" do
    it "returns DefaultAffiliateTemplate when nil" do
      affiliate = Affiliate.create!(@valid_attributes)
      affiliate.template.should == DefaultAffiliateTemplate
    end

    it "returns affiliate template when not nil" do
      affiliate = Affiliate.create!(@valid_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.template.should == affiliate_templates(:basic_gray)
    end
  end
  
  describe "#is_owner" do
    before do
      @affiliate = Affiliate.create(@valid_attributes)
    end
    
    it "should return true if the user specified is the owner of the affiliate" do
      @affiliate.is_owner?(users(:affiliate_manager)).should be_true
    end
    
    it "should return false if the user specified is not the owner of the affiliate" do
      @affiliate.is_owner?(users(:another_affiliate_manager)).should be_false
    end
  end
end