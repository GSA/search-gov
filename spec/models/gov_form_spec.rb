require 'spec_helper'

describe GovForm do
  before(:each) do
    @valid_attributes = {
      :name => 'Some form name',
      :form_number => 'R2D2_C3P0',
      :agency => 'An Agency',
      :bureau => 'A Bureau',
      :description => 'This is a description; there is not really anything important or interesting here, we just want to make sure that the description is at least two hundred and fifty five characters long so that we have enough text to make sure that we are not limited in terms of number of characters.',
      :url => 'http://something.com/some/link'
    }
  end

  it "should create a new instance given valid attributes" do
    GovForm.create!(@valid_attributes)
  end
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :form_number }
  it { should validate_presence_of :agency }
  it { should validate_presence_of :description }
  it { should validate_presence_of :url }
end
