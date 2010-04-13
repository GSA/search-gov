require "#{File.dirname(__FILE__)}/../spec_helper"

describe AcceptedSaytSuggestion do
  before(:each) do
    @valid_attributes = {
      :phrase => "some accepted suggestion"
    }
  end

  describe "Creating new instance" do
    should_validate_presence_of :phrase

    it "should create a new instance given valid attributes" do
      AcceptedSaytSuggestion.create!(@valid_attributes)
    end

  end

end
