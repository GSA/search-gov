require 'spec/spec_helper'
describe "shared/_related_topics.html.haml" do
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
    end

    it  "should display related topics" do
      render
      rendered.should have_selector('h3', :content => 'Related Topics to <i>tax forms</i>')
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
    end

    it  "should not display related topics" do
      render
      rendered.should_not have_selector('ul', :id => 'relatedsearch')
    end
  end
end
