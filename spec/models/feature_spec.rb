require 'spec_helper'

describe Feature do
  fixtures :features

  let(:valid_attributes) { {:display_name => "Awesome Feature", :internal_name => "awesome_feature"} }

  describe "#label" do
    it "should return the display name" do
      f = features(:disco)
      f.label.should == f.display_name
    end
  end

  describe "creating a new Feature" do
    it { should validate_presence_of :internal_name }
    it { should validate_presence_of :display_name }
    it { should validate_uniqueness_of :internal_name }
    it { should validate_uniqueness_of :display_name }
    it { should have_many(:affiliates) }
    it { should have_many(:affiliate_feature_addition).dependent(:destroy) }
    it "should create a new instance given valid attributes" do
      Feature.create!(valid_attributes)
    end
  end
end
