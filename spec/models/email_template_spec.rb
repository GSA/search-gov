require 'spec/spec_helper'

describe EmailTemplate do
  before do
    @valid_attributes = {
      :name => 'email_template',
      :body => 'Hello, World.'
    }
  end
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :body }
  it "should create a new instance given valid attributes" do
    EmailTemplate.create!(@valid_attributes)
    
    should validate_uniqueness_of :name
  end
  
  describe "#load_default_templates" do
    it "should load all the templates when no parameter is passed in" do
      EmailTemplate.load_default_templates
      EmailTemplate.count.should == 14
    end    
  end
end
