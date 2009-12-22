require "#{File.dirname(__FILE__)}/../../spec_helper"
describe "searches/index.html.haml" do
  before do
    @search = stub("Search")
    @search.stub!(:related_search).and_return []
    assigns[:search] = @search
  end

  context "when spelling suggestion is available" do
    before do
      @search.stub!(:query).and_return "U mispeled everytheeng"
      @search.stub!(:spelling_suggestion).and_return "You misspelled everything"
      @search.stub!(:results).and_return []
      @search.stub!(:boosted_sites).and_return []
      @search.stub!(:error_message).and_return "Ignore me"
    end

    it "should show the spelling suggestion" do
      render
      response.should contain("You misspelled everything")
    end
  end

  context "when there is a blank search" do
    before do
      @search.stub!(:query).and_return ""
      @search.stub!(:spelling_suggestion).and_return nil
      @search.stub!(:results).and_return []
      @search.stub!(:boosted_sites).and_return []      
      @search.stub!(:error_message).and_return "Enter some search terms"
    end

    it "should show header search form but not show footer search form" do
      render
      response.should contain("Enter some search terms")
      response.should have_selector("#search_query_auto_complete")
      response.should_not have_selector("#footer_search_form")
    end
  end

  context "when there are search results" do
    before do
      @search.stub!(:query).and_return "some query"
      @search.stub!(:spelling_suggestion).and_return nil
      @search.stub!(:images).and_return []
      @search.stub!(:error_message).and_return nil
      @search.stub!(:startrecord).and_return 1
      @search.stub!(:endrecord).and_return "don't care"
      @search.stub!(:total).and_return "don't care"
      @search_result = {'title' => "some title",
                       'unescapedUrl'=> "http://www.foo.com/url",
                       'content'=> "This is a sample result",
                       'cacheUrl'=> "http://www.cached.com/url"
      }
      @search_results = []
      @search_results.stub!(:total_pages).and_return 1
      @search.stub!(:results).and_return @search_results
      @search.stub!(:boosted_sites).and_return []
    end

    context "when there are fewer than five results" do
      before do
        4.times { @search_results << @search_result }
      end

      it "should show header search form but not show footer search form" do
        render
        response.should have_selector("#search_query_auto_complete")
        response.should_not have_selector("#footer_search_form")
      end
    end

    context "when there are five results" do
      before do
        5.times { @search_results << @search_result }
      end

      it "should show header search form and footer search form" do
        render
        response.should have_selector("#search_query_auto_complete")
        response.should have_selector("#footer_search_form")
      end
    end
  end
end