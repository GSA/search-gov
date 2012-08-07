require 'spec_helper'

describe "Recalls" do
  it "should map /recalls/index.xml to the recalls rss feed" do
    get "/recalls/index.xml"
    response.success?.should be_true
    response.content_type.should == 'application/rss+xml'
    response.body.should =~ /Search.USA.gov Recalls Feed/
  end
end

