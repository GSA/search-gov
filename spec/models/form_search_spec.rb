require "#{File.dirname(__FILE__)}/../spec_helper"

describe FormSearch do
  before do
    @valid_options = {
      :query => 'taxes'
    }
  end
  
  describe "#run" do    
    it "should return an empty related search set" do
      search = FormSearch.new(@valid_options)
      search.run
      search.related_search.should be_empty
    end
    
    it "should use the forms scope when doing a search" do
      search = FormSearch.new(@valid_options)
      uriresult = URI::parse('http://localhost:3000')
      URI.should_receive(:parse).with(/\(form%20OR%20forms\)%20\(site%3Agov%20OR%20site%3Amil%20OR%20site%3Ausps.com\)%20\(filetype%3Apdf%20OR%20contains%3Apdf\)/).and_return(uriresult)
      search.run
    end
  end
end