require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Affiliate do
  fixtures :users, :affiliates, :affiliate_templates

  before(:each) do
    @valid_create_attributes = {
      :display_name => "My Awesome Site",
      :domains => "someaffiliate.gov",
      :website => "http://www.someaffiliate.gov",
      :header => "<table><tr><td>html layout from 1998</td></tr></table>",
      :footer => "<center>gasp</center>",
      :owner => users(:affiliate_manager),
    }

    @valid_attributes = @valid_create_attributes.merge(:name => "someaffiliate.gov")
  end

  describe "Creating new instance of Affiliate" do
    should_validate_presence_of :display_name
    should_validate_uniqueness_of :name, :case_sensitive => false
    should_validate_length_of :name, :within=> (3..33)
    should_not_allow_values_for :name, "<IMG SRC=", "259771935505'", "spacey name", "NewAff"
    should_allow_values_for :name, "data.gov", "ct-new", "some_aff", "123"
    should_belong_to :owner
    should_have_and_belong_to_many :users
    should_have_many :boosted_contents
    should_have_many :sayt_suggestions
    should_have_many :calais_related_searches

    it "should create a new instance given valid attributes" do
      Affiliate.create!(@valid_create_attributes)
    end

    it "should generate HTTP parameter site name based on display name" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "Affiliate site"))
      affiliate.name.should == "affiliatesite"
    end

    describe "on create" do
      it "should generate HTTP parameter site name based on MD5 hash value when the display name is too short" do
        Digest::MD5.should_receive(:hexdigest).and_return("hexvalue")
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "A"))
        affiliate.name.should == "hexvalue"
      end

      it "should generate HTTP parameter site name based on MD5 hash value if display name contains less than 3 valid characters" do
        Digest::MD5.should_receive(:hexdigest).and_return("hexvalue")
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "3!!"))
        affiliate.name.should == "hexvalue"
      end

      it "should generate HTTP parameter site name using MD5 hash value when the candidate HTTP parameter site name already exists" do
        Digest::MD5.should_receive(:hexdigest).and_return("hexvalue")
        first_affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "Affiliate site123___----...."))
        first_affiliate.name.should == "affiliatesite123___----...."
        second_affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "Affiliate site123___----...."))
        second_affiliate.name.should == "hexvalue"
      end

      it "should generate HTTP parameter site name with 33 characters if display name is greater than 33 characters" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "1234567890!!1234567890!!1234567890!!123456"))
        affiliate.name.should == "123456789012345678901234567890123"
      end

      it "should generate HTTP parameter site name with 3 characters if display name is 3 characters" do
        affiliate = Affiliate.create!(@valid_create_attributes.merge(:display_name => "123"))
        affiliate.name.should == "123"
      end
    end

    it "should validate presence of :name on update" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.update_attributes(:name => "").should_not be_true
    end

    it "should have SAYT enabled by default" do
      Affiliate.create!(@valid_create_attributes).is_sayt_enabled.should be_true
    end

    it "should have Affiliate-specific SAYT suggestions enabled by default" do
      Affiliate.create!(@valid_create_attributes).is_affiliate_suggestions_enabled.should be_true
    end
    
    it "should generate a database-level error when attempting to add an affiliate with the same name as an existing affiliate, but with different case; instead it should return false" do
      Affiliate.create!(@valid_attributes)
      @duplicate_affiliate = Affiliate.new(@valid_attributes.merge(:name => @valid_attributes[:name].upcase))
      @duplicate_affiliate.save.should be_false
    end

    it "should set the affiliate_template_id to the default affiliate_template_id" do
      affiliate = Affiliate.create!(@valid_create_attributes)
      affiliate.affiliate_template.should == affiliate_templates(:default)
    end

    it "should set the affiliate_template_id to the default affiliate_template_id" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
    end
  end

  describe "#template" do
    it "should return the affiliate template if present" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
      affiliate.template.should == affiliate.affiliate_template
    end

    it "should return the default affiliate template if no affiliate template" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:affiliate_template_id => -1))
      affiliate.affiliate_template.should be_nil
      affiliate.template.should == AffiliateTemplate.default_template
    end
  end

  describe "on save" do
    it "should set the affiliate_template_id to the default affiliate_template_id if saved with no affiliate_template_id" do
      affiliate = Affiliate.create!(@valid_create_attributes.merge(:affiliate_template => affiliate_templates(:basic_gray)))
      affiliate.affiliate_template.should == affiliate_templates(:basic_gray)
      Affiliate.find(affiliate.id).update_attributes(:affiliate_template_id => "")
      Affiliate.find(affiliate.id).affiliate_template.should == affiliate_templates(:default)
    end
  end

  describe "#is_owner" do
    before do
      @affiliate = Affiliate.create(@valid_create_attributes)
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
      affiliate = Affiliate.create(@valid_create_attributes.merge(:related_topics_setting => nil))
      affiliate.is_affiliate_related_topics_enabled?.should be_true
    end
    
    it "should return true if the value of related_topics_setting is 'affiliate_enabled'" do
      affiliate = Affiliate.create(@valid_create_attributes.merge(:related_topics_setting => 'affiliate_enabled'))
      affiliate.is_affiliate_related_topics_enabled?.should be_true
    end
    
    it "should return true if the value is set to anything other than 'global_enabled' or 'disabled'" do
      affiliate = Affiliate.create(@valid_create_attributes.merge(:related_topics_setting => 'bananas'))
      affiliate.is_affiliate_related_topics_enabled?.should be_true
      affiliate = Affiliate.create(@valid_create_attributes.merge(:related_topics_setting => 'global_enabled'))
      affiliate.is_affiliate_related_topics_enabled?.should be_false
      affiliate = Affiliate.create(@valid_create_attributes.merge(:related_topics_setting => 'disabled'))
      affiliate.is_affiliate_related_topics_enabled?.should be_false
    end
  end

  describe "#human_attribute_name" do
    Affiliate.human_attribute_name("display_name").should == "Site name"
    Affiliate.human_attribute_name("name").should == "HTTP parameter site name"
  end
end
