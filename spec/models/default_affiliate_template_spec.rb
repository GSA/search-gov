require 'spec_helper'

describe DefaultAffiliateTemplate do
  describe ".name" do
    it "is Default" do
      DefaultAffiliateTemplate.name.should == "Default"
    end
  end
  
  describe ".stylesheet" do
    it "is default" do
      DefaultAffiliateTemplate.stylesheet.should == "default"
    end
  end
end
