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

  describe ".description" do
    it "is default" do
      DefaultAffiliateTemplate.description.should == "Default template"
    end
  end
end
