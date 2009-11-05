require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliatesController do
  fixtures :affiliates

  describe "#index" do
    it "should assign a list of affiliates" do
      affiliates = Affiliate.all
      Affiliate.should_receive(:all).once.and_return(affiliates)
      get :index
      assigns[:affiliates].should == affiliates
    end
  end
end
