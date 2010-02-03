require "#{File.dirname(__FILE__)}/../spec_helper"

describe Spotlight do
  fixtures :spotlights, :spotlight_keywords

  before(:each) do
    @valid_attributes = {
      :title=>"My Spotlight",
      :html=>"Some HTML in a DIV",
      :notes=>"This is notable",
      :is_active => 1
    }
  end

  describe "Creating new instance" do
    should_validate_presence_of :title
    should_validate_uniqueness_of :title
    should_have_many :spotlight_keywords

    it "should create a new instance given valid attributes" do
      Spotlight.create!(@valid_attributes)
    end
  end

  describe "#search_for" do
    integrate_sunspot

    before do
      @spotty = spotlights(:time)
    end

    context "when a relevant spotlight is active" do
      before do
        Spotlight.reindex
      end

      it "should return a Spotlight" do
        Spotlight.search_for("time").should == @spotty
      end
    end

    context "when an otherwise relevant spotlight is inactive" do
      before do
        @spotty.update_attribute(:is_active, false)
        Spotlight.reindex
      end

      it "should return nil" do
        Spotlight.search_for("time").should be_nil
      end
    end
  end
end
