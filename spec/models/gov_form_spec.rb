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
  
  should_validate_presence_of :name, :form_number, :agency, :description, :url
end
