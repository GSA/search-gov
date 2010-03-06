require 'spec_helper'

describe AffiliateTemplate do
  it "requires name" do
    affiliate_template = AffiliateTemplate.new(:name => nil)
    affiliate_template.should_not be_valid
    affiliate_template.should have_at_least(1).error_on(:name)
  end
    
  it "requires stylesheet" do
    affiliate_template = AffiliateTemplate.new(:stylesheet => nil)
    affiliate_template.should_not be_valid
    affiliate_template.should have_at_least(1).error_on(:stylesheet)
  end
  
  it "ensures unique stylesheet" do
    AffiliateTemplate.create!(:name => "Foo", :stylesheet => "Bar")    
    lambda {
      AffiliateTemplate.create!(:name => "Foo", :stylesheet => "Bar")
    }.should raise_error
  end
end
