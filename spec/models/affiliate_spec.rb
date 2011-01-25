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
    should_validate_uniqueness_of :name, :case_sensitive => false
    should_validate_length_of :name, :within=> (3..33)
    should_not_allow_values_for :name, "<IMG SRC=", "259771935505'", "spacey name"
    should_allow_values_for :name, "data.gov", "ct-new", "NewAff", "some_aff", "123"
    should_belong_to :owner
    should_have_and_belong_to_many :users
    should_have_many :boosted_contents
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
    
    it "should not generate a database-level error when attempting to add an affiliate with the same name as an existing affiliate, but with different case; instead it should return false" do
      Affiliate.create!(@valid_attributes)
      @duplicate_affiliate = Affiliate.new(@valid_attributes.merge(:name => @valid_attributes[:name].upcase))
      @duplicate_affiliate.save.should be_false
    end

    it "should set the affiliate_template_id to the default affiliate_template_id" do
      affiliate = Affiliate.create!(@valid_attributes)
      affiliate.affiliate_template.should == affiliate_templates(:default)
    end

    it "should set the affiliate_template_id to the default affiliate_template_id" do
      affiliate = Affiliate.create!(@valid_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
    end
  end

  describe "#template" do
    it "should return the affiliate template if present" do
      affiliate = Affiliate.create!(@valid_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
      affiliate.template.should == affiliate.affiliate_template
    end

    it "should return the default affiliate template if no affiliate template" do
      affiliate = Affiliate.create!(@valid_attributes.merge(:affiliate_template_id => -1))
      affiliate.affiliate_template.should be_nil
      affiliate.template.should == AffiliateTemplate.default_template
    end
  end

  describe "on save" do
    it "should set the affiliate_template_id to the default affiliate_template_id if saved with no affiliate_template_id" do
      affiliate = Affiliate.create!(@valid_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
      Affiliate.find(affiliate.id).update_attributes(:affiliate_template_id => "")
      Affiliate.find(affiliate.id).affiliate_template.should == affiliate_templates(:default)
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
  
  describe "#is_affiliate_related_topics_enabled?" do
    it "should return true if the value of related_topics_setting is nil" do
      affiliate = Affiliate.create(@valid_attributes.merge(:related_topics_setting => nil))
      affiliate.is_affiliate_related_topics_enabled?.should be_true
    end
    
    it "should return true if the value of related_topics_setting is 'affiliate_enabled'" do
      affiliate = Affiliate.create(@valid_attributes.merge(:related_topics_setting => 'affiliate_enabled'))
      affiliate.is_affiliate_related_topics_enabled?.should be_true
    end
    
    it "should return true if the value is set to anything other than 'global_enabled' or 'disabled'" do
      affiliate = Affiliate.create(@valid_attributes.merge(:related_topics_setting => 'bananas'))
      affiliate.is_affiliate_related_topics_enabled?.should be_true
      affiliate = Affiliate.create(@valid_attributes.merge(:related_topics_setting => 'global_enabled'))
      affiliate.is_affiliate_related_topics_enabled?.should be_false
      affiliate = Affiliate.create(@valid_attributes.merge(:related_topics_setting => 'disabled'))
      affiliate.is_affiliate_related_topics_enabled?.should be_false
    end
  end
end
