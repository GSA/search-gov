require 'spec/spec_helper'

describe FormSearch do

  describe "#run" do
    before do
      @search = FormSearch.new({:query => 'taxes'})
    end

    it "should return an empty related search set" do
      @search.run
      @search.related_search.should be_empty
    end

    it "should use the forms scope when doing a search" do
      uriresult = URI::parse('http://localhost:3000')
      URI.should_receive(:parse).with(/\(form%20OR%20forms\)%20\(site%3Agov%20OR%20site%3Amil%20OR%20site%3Ausps.com\)%20\(filetype%3Apdf%20OR%20contains%3Apdf\)/).and_return(uriresult)
      @search.run
    end

    it "should log info about the query" do
      QueryImpression.should_receive(:log).with(:form, Affiliate::USAGOV_AFFILIATE_NAME, 'taxes', ["BWEB"])
      @search.run
    end

  end
end