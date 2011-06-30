require 'spec/spec_helper'
describe "shared/_relatedsearches.html.haml" do
  before do
    @search = stub("Search")
    @related_searches = ["first-1 keeps the hyphen", "second one is a string", "CIA stays capitalized", "utilización de gafas del sol durante el tiempo"]
    @search.stub!(:related_search).and_return @related_searches
    @search.stub!(:queried_at_seconds).and_return(1271978870)
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

      @deep_link = mock("DeepLink")
      @deep_link.stub!(:title).and_return 'A title'
      @deep_link.stub!(:url).and_return 'http://adeeplink.com'
      @search_result = {'title' => "some title",
                       'unescapedUrl'=> "http://www.foo.com/url",
                       'content'=> "This is a sample result",
                       'cacheUrl'=> "http://www.cached.com/url",
                       'deepLinks' => [ @deep_link ]
      }
      @search_results = []
      @search_results.stub!(:total_pages).and_return 1
      @search.stub!(:results).and_return @search_results
      @search.stub!(:spotlight).and_return nil
      @search.stub!(:boosted_contents).and_return nil
      @search.stub!(:faqs).and_return nil
      @search.stub!(:gov_forms).and_return nil
      @search.stub!(:agency).and_return nil
      @search.stub!(:med_topic).and_return nil

      10.times { @search_results << @search_result }
      assign(:search, @search)
    end

    it "should not display related search results" do
      render
      rendered.should_not have_selector('h3', :content => 'Related Topics to tax forms by USA.gov')
    end

    context "when doing an affiliate search" do
      before do
        @affiliate = stub('affiliate', :name => 'test')
      end

      it  "should display related search results" do
          render
          rendered.should have_selector('h3', :content => 'Related Topics')
          rendered.should have_selector('ul', :id => 'relatedsearch')
          rendered.should have_selector('a', :content => 'CIA Stays Capitalized')
          rendered.should have_selector('a', :content => 'First-1 Keeps the Hyphen')
          rendered.should have_selector('a', :content => 'Second One Is a String')
          rendered.should have_selector('a', :content => 'Utilización de Gafas del Sol durante el Tiempo')
      end
    end

    context "when there are related FAQ results" do
      before do
        @faqs = Faq.search_for(@search.query)
        @faqs.stub!(:total).and_return 3
        @search.stub!(:faqs).and_return @faqs
        assign(:search, @search)
      end

      it "should display related FAQ results" do
        render
        rendered.should have_selector('ul', :id => 'related_faqs')
      end
    end
  end
end