require 'spec/spec_helper'

describe SaytController do
  fixtures :affiliates
  before do
    @affiliate = affiliates(:usagov_affiliate)
    @suggestion = SaytSuggestion.create!(:phrase => "Lorem ipsum dolor sit amet", :affiliate => @affiliate)
    SaytSuggestion.create!(:phrase => "Lorem sic transit gloria", :affiliate => @affiliate)
  end

  it "should return empty JSONP if no aid is present" do
    get '/sayt', :q => 'lorem', :callback => 'jsonp1276290049647'
    response.body.should == 'jsonp1276290049647([])'
  end

  it "should return empty JSONP if nothing matches the 'q' param string" do
    get '/sayt', :q=>"who moved my cheese", :callback => 'jsonp1276290049647', :aid => @affiliate.id
    response.body.should == 'jsonp1276290049647([])'
  end

  it "should not completely melt down when strange characters are present" do
    lambda { get '/sayt', :q=>"foo\\", :callback => 'jsonp1276290049647', :aid => @affiliate.id }.should_not raise_error
    lambda { get '/sayt', :q=>"foo's", :callback => 'jsonp1276290049647', :aid => @affiliate.id }.should_not raise_error
  end

  it "should return empty result if no params present" do
    get '/sayt'
    response.body.should == ''
  end

  it "should return empty result if query term is all whitespace" do
    get '/sayt', :q=>"  ", :callback => 'jsonp1276290049647', :aid => @affiliate.id
    response.body.should == ''
  end

  it "should call Search.suggestions with a whitespace-normalized string" do
    WebSearch.should_receive(:suggestions).with(nil, 'does torture', an_instance_of(Fixnum)).and_return []
    get '/sayt', :q=>"does  torture ", :callback => 'jsonp1276290049647'
  end

  context "when searching in non-mobile mode" do
    it "should return 15 suggestions" do
      WebSearch.should_receive(:suggestions).with(nil, "lorem", 15).and_return([@suggestion])
      get '/sayt', :q=>"lorem", :callback => 'jsonp1276290049647'
    end
  end

  context "when affiliate id parameter (aid) is specified" do
    it "should use it to find suggestions for that affiliate" do
      WebSearch.should_receive(:suggestions).with("370", "lorem", 15).and_return([@suggestion])
      get '/sayt', :aid=> "370", :q=>"lorem", :callback => 'jsonp1276290049647'
    end
  end

  context "when affiliate id parameter (aid) is not specified" do
    it "should use a null affiliate id to get the generic site-wide suggestions" do
      WebSearch.should_receive(:suggestions).with(nil, "lorem", 15).and_return([@suggestion])
      get '/sayt', :q=>"lorem", :callback => 'jsonp1276290049647'
    end
  end
  
  context "when searching in mobile mode" do
    it "should return 6 suggestions" do
      SaytController.class_eval { def is_mobile_device?; true; end }
      WebSearch.should_receive(:suggestions).with(nil, "lorem", 6).and_return([@suggestion])
      get '/sayt', :q => "lorem", :callback => 'jsonp1276290049647'
    end
  end
end