require 'spec_helper'

describe SearchModule do
  fixtures :search_modules

  before(:each) do
    @valid_attributes = {
      :display_name => "Some name",
      :tag => "IMATAG"
    }
  end

  describe "Creating new instance" do
    it { should validate_presence_of :tag }
    it { should validate_presence_of :display_name }
    it { should validate_uniqueness_of :tag }

    it "should create a new instance given valid attributes" do
      SearchModule.create!(@valid_attributes)
    end
  end
end
