require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliatesController do
  fixtures :affiliates

  describe "#index" do
    it "should assign a list of affiliaate objects and headings" do
      get :index
      assigns[:objects].should_not be_nil
      assigns[:headings].should_not be_nil
    end
  end
end
