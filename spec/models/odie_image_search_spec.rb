require 'spec/spec_helper'

describe OdieSearch do
  fixtures :affiliates
  
  before do
    @affiliate = affiliates(:basic_affiliate)
  end
  
  describe "#cache_key" do
    it "should output a key based on the query, affiliate id, and page parameters" do
      OdieImageSearch.new(:query => 'element', :affiliate => @affiliate, :page => 4).cache_key.should == "odie_image:element:#{@affiliate.id}:4:10"
    end
  end
end