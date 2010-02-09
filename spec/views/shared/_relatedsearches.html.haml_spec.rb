require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "shared/_relatedsearches.html.haml" do
  before do
    @search = stub("Search")
    @related_search.stub!(:title).and_return 'A Title'
    @related_search.stub!(:url).and_return 'http://arelatedurl.com'
    @search.stub!(:related_search).and_return [ @related_search, @related_search ]
    assigns[:search] = @search
  end
  
  context "when page is displayed" do
    before do
      @search.stub!(:query).and_return "tax forms"
      @search.stub!(:spelling_suggestion).and_return nil
      @search.stub!(:images).and_return []
      @search.stub!(:error_message).and_return nil
      @search.stub!(:startrecord).and_return 1
      @search.stub!(:endrecord).and_return 10
      @search.stub!(:total).and_return 20
      @search.stub!(:page).and_return 0
      
      @deepLink.stub!(:title).and_return 'A title'
      @deepLink.stub!(:url).and_return 'http://adeeplink.com'
      @search_result = {'title' => "some title",
                       'unescapedUrl'=> "http://www.foo.com/url",
                       'content'=> "This is a sample result",
                       'cacheUrl'=> "http://www.cached.com/url",
                       'deepLinks' => [ @deepLink ]
      }
      @search_results = []
      @search_results.stub!(:total_pages).and_return 1
      @search.stub!(:results).and_return @search_results
      @search.stub!(:spotlight).and_return nil
      @search.stub!(:boosted_sites).and_return nil
      @search.stub!(:faqs).and_return nil
      @search.stub!(:gov_forms).and_return nil
      
      10.times { @search_results << @search_result }
    end
    
    it "should display related search results" do
      render :locals => { :search => @search }
      response.should have_tag('h3', :text => 'Related Searches')
      response.should have_tag('ul', :id => 'relatedsearch')
    end
    
    context "when there are related FAQ results" do
      before do
        @faqs = Faq.search_for(@search.query)
        @search.stub!(:faqs).and_return @faqs         
      end
      
      it "should display related FAQ results" do
        render :locals => { :search => @search }
        response.should have_tag('ul', :id => 'related_faqs')
      end
    end
    
    context "when there are related GovForm results" do
      before do
        @gov_forms = GovForm.search_for(@search.query)
        @search.stub!(:gov_forms).and_return @gov_forms
      end
      
      it "should display related GovForm results" do
        render :locals => { :search => @search }
        response.should have_tag('ul', :id => 'related_gov_forms')
      end
    end
    
  end
  
end