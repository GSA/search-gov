require 'spec/spec_helper'
describe "shared/_related_topics_wrapper.html.haml" do
  before do
    @search = stub("Search")
    @search.stub!(:queried_at_seconds).and_return(1271978870)
    @search.stub!(:query).and_return "<i>tax forms</i>"
    @search.stub!(:spelling_suggestion).and_return nil
    assign(:search, @search)
  end

  context "when there are related topics" do
    before do
      @related_searches = ["first-1 keeps the hyphen", "second one is a string", "CIA stays capitalized", "utilización de gafas del sol durante el tiempo"]
      @search.stub!(:related_search).and_return @related_searches
      @search.stub!(:related_search_class).and_return "SaytSuggestion"
      @search.stub!(:has_related_searches?).and_return true
    end

    it  "should display related topics" do
      render
      rendered.should have_selector('h3', :content => 'Related Searches for <i>tax forms</i>')
      rendered.should have_selector('ul', :id => 'relatedsearch')
      rendered.should have_selector('a', :content => 'CIA Stays Capitalized')
      rendered.should have_selector('a', :content => 'First-1 Keeps the Hyphen')
      rendered.should have_selector('a', :content => 'Second One Is a String')
      rendered.should have_selector('a', :content => 'Utilización de Gafas del Sol durante el Tiempo')
    end
  end

  context "when there are no related topics" do
    before do
      @related_searches = []
      @search.stub!(:related_search).and_return @related_searches
      @search.stub!(:has_related_searches?).and_return false
    end

    it  "should not display related topics" do
      render
      rendered.should_not have_selector('ul', :id => 'relatedsearch')
    end
  end

  context "when there are related topics in affiliate embedded search mode" do
    fixtures :affiliates
    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      @related_searches = ["first-1 keeps the hyphen", "second one is a string", "CIA stays capitalized", "utilización de gafas del sol durante el tiempo"]
      @search.stub!(:related_search).and_return @related_searches
      @search.stub!(:related_search_class).and_return "SaytSuggestion"
      @search.stub!(:has_related_searches?).and_return true
      assign(:affiliate, affiliate)
      assign(:search_options, {:embedded => true} )
    end

    it  "should display related topics" do
      view.should_receive(:search_path).exactly(4).times.with(hash_including(:embedded => true))
      render
      rendered.should have_selector('ul', :id => 'relatedsearch')
      rendered.should have_selector("#relatedsearch a", :count => 4)
    end
  end

end
