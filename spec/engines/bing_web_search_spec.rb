# coding: utf-8
require 'spec_helper'

describe BingWebSearch do

  it_behaves_like "a web search engine"

  describe ".new for BingWebSearch" do
    it 'should set Web and Spell index sources' do
      BingWebSearch.new.sources.should == 'Spell Web'
    end

    context 'when only required search params are passed in' do
      let(:minimum_search) { BingWebSearch.new(query: "taxes") }
      it 'should set appropriate defaults' do
        minimum_search.query.should == 'taxes'
        minimum_search.filter_level.should == 'moderate'
        minimum_search.enable_highlighting.should be_true
      end
    end

    context 'when all search params are passed in' do
      let(:fully_specified_search) { BingWebSearch.new(query: "taxes", offset: 11, filter: 2, enable_highlighting: false, per_page: 25) }
      it 'should set appropriate values from params' do
        fully_specified_search.query.should == 'taxes'
        fully_specified_search.offset.should == 11
        fully_specified_search.per_page.should == 25
        fully_specified_search.filter_level.should == 'strict'
        fully_specified_search.enable_highlighting.should be_false
      end
    end

    describe "adult content filters" do
      context "when a valid filter parameter is present" do
        it "should set the filter_level parameter to the Bing-specific level" do
          BingWebSearch.new(query: "taxes", filter: 0).filter_level.should == 'off'
          BingWebSearch.new(query: "taxes", filter: 1).filter_level.should == 'moderate'
          BingWebSearch.new(query: "taxes", filter: 2).filter_level.should == 'strict'
        end
      end

      context "when the filter parameter is blank/invalid" do
        it "should set the filter_level parameter to the default value (moderate)" do
          BingWebSearch.new(query: "taxes", filter: '').filter_level.should == 'moderate'
          BingWebSearch.new(query: "taxes", filter: 'whatevs').filter_level.should == 'moderate'
        end
      end
    end

  end

  describe "processing results" do
    before do
      bing_api_url = "#{BingSearch::API_HOST}#{BingSearch::API_ENDPOINT}"
      searches = %w{ total_no_results missing_urls missing_descriptions missing_title }

      searches.each do |search|
        result = Rails.root.join("spec/fixtures/json/bing/web_search/#{search}.json").read
        stub_request(:get, /#{bing_api_url}.*#{search}/).
          to_return(status: 200, body: result)
      end
    end

    context "when results contain a listing missing a title" do
      let(:search) { BingWebSearch.new(query: "missing_title") }

      it "should ignore that result" do
        search_engine_response = search.execute_query
        search_engine_response.results.size.should == 1
      end
    end

    context "when results contain a listing that is missing a url" do
      let(:search) { BingWebSearch.new(query: "missing_urls") }

      it "should ignore that result" do
        search_engine_response = search.execute_query
        search_engine_response.results.size.should == 9
        search_engine_response.results.each do |result|
          result.unescaped_url.should be_present
        end
      end
    end

    context "when results contain a listing that is missing a description" do
      let(:search) { BingWebSearch.new(query: "missing_descriptions") }

      it "should use a blank description" do
        search_engine_response = search.execute_query
        search_engine_response.results.size.should == 10
        search_engine_response.results.each do |result|
          result.content.should be_blank
        end
      end
    end

    context "when Bing reports a total > 0 but gives no results whatsoever" do
      let(:search) { BingWebSearch.new(query: "total_no_results") }

      it "should return zero for the number of hits" do
        search_engine_response = search.execute_query
        search_engine_response.total.should == 0
      end
    end

  end
end
