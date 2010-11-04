require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SuperfreshController do
  describe "#index" do
    integrate_views
    it "should set the request fomat to :rss, and render as rss/xml" do
      get :index
      response.content_type.should == 'application/rss+xml'
      response.body.should contain(/Search.USA.gov Superfresh Feed/)
      response.body.should contain(/Recently updated URLs from around the US Government/)
      response.body.should contain(/search.usa.gov/)
    end
  end
end