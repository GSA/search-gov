# coding: utf-8
require 'spec_helper'

describe "shared/_related_topics.html.haml" do
  fixtures :affiliates

  before do
    @search = stub("Search")
    @search.stub!(:queried_at_seconds).and_return(1271978870)
    @search.stub!(:query).and_return "<i>tax forms</i>"
    @search.stub!(:spelling_suggestion).and_return nil
    assign(:search, @search)
    assign(:affiliate, affiliates(:usagov_affiliate))
  end

  context "when there are related topics" do
    before do
      @related_searches = ["first-1 keeps the hyphen", "second one is a string", "CIA gets downcased", "utilización de gafas del sol durante el tiempo"]
      @search.stub!(:related_search).and_return @related_searches
      @search.stub!(:has_related_searches?).and_return true
    end

    it  "should display related topics" do
      render
      rendered.should have_selector('#related_searches')
      rendered.should have_selector('h3', :content => %q{Related Searches for '<i>tax forms</i>'})
      rendered.should have_selector('a', :content => 'cia gets downcased')
      rendered.should have_selector('a', :content => 'first-1 keeps the hyphen')
      rendered.should have_selector('a', :content => 'second one is a string')
      rendered.should have_selector('a', :content => 'utilización de gafas del sol durante el tiempo')
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
      rendered.should_not have_selector('#related_searches')
    end
  end

  context "when there are related topics in affiliate embedded search mode" do
    fixtures :affiliates
    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      @related_searches = ["first-1 keeps the hyphen", "second one is a string", "CIA gets downcased", "utilización de gafas del sol durante el tiempo"]
      @search.stub!(:related_search).and_return @related_searches
      @search.stub!(:has_related_searches?).and_return true
      assign(:affiliate, affiliate)
      assign(:search_options, {:embedded => true} )
    end

    it  "should display related topics" do
      view.should_receive(:search_path).exactly(4).times.with(hash_including(:embedded => true))
      render
      rendered.should have_selector("#related_searches a", :count => 4)
    end
  end

end
