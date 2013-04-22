# coding: utf-8
require 'spec_helper'

describe BingWebSearch do
  before do
    common = '/json.aspx?Adult=moderate&AppId=A4C32FAE6F3DB386FC32ED1C4F3024742ED30906&sources=Spell+Web&'
    hl='Options=EnableHighlighting&'
    stubs = Faraday::Adapter::Test::Stubs.new
    generic_bing_result = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/ira.json")
    stubs.get("#{common}#{hl}query=highlight+enabled") { [200, {}, generic_bing_result] }
    generic_bing_result_no_highlight = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/ira_no_highlight.json")
    stubs.get("#{common}query=no+highlighting&web.offset=11") { [200, {}, generic_bing_result_no_highlight] }
    stubs.get("#{common}#{hl}query=casa+blanca") { [200, {}, generic_bing_result] }
    stubs.get("#{common}#{hl}query=english") { [200, {}, generic_bing_result] }

    two_results_1_missing_title = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/2_results_1_missing_title.json")
    stubs.get("#{common}#{hl}query=2missing1") { [200, {}, two_results_1_missing_title] }

    missing_descriptions = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/missing_descriptions.json")
    stubs.get("#{common}#{hl}query=missing_descriptions") { [200, {}, missing_descriptions] }

    no_results = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/no_results.json")
    stubs.get("#{common}#{hl}query=no_results") { [200, {}, no_results] }

    @test = Faraday.new do |builder|
      builder.adapter :test, stubs
      builder.response :rashify
      builder.response :json
    end
    Faraday.stub!(:new).and_return @test
  end

  it_behaves_like "a search engine"

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
      let(:fully_specified_search) { BingWebSearch.new(query: "taxes", offset: 11, filter: 2, enable_highlighting: false) }
      it 'should set appropriate values from params' do
        fully_specified_search.query.should == 'taxes'
        fully_specified_search.offset.should == 11
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
    context "when results contain a listing missing a title" do
      let(:search) { BingWebSearch.new(query: "2missing1") }

      it "should ignore that result" do
        search_engine_response = search.execute_query
        search_engine_response.results.size.should == 1
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

  end
end