# coding: utf-8
require 'spec_helper'

describe GoogleSearch do
  before do
    common = '/customsearch/v1?alt=json&key=AIzaSyAqgqnBqdXKtLfmEEzarf96hlnzD5koi34&cx=015426204394000049396:9fkj8sbnfpi'
    common_params = '&lr=lang_en&safe=medium'
    stubs = Faraday::Adapter::Test::Stubs.new
    generic_google_result = File.read(Rails.root.to_s + "/spec/fixtures/json/google/web_search/ira.json")
    stubs.get("#{common}#{common_params}&q=highlight+enabled") { [200, {}, generic_google_result] }
    stubs.get("#{common}#{common_params}&q=no+highlighting") { [200, {}, generic_google_result] }
    stubs.get("#{common}&lr=lang_es&safe=medium&q=casa+blanca") { [200, {}, generic_google_result] }
    stubs.get("#{common}#{common_params}&q=english") { [200, {}, generic_google_result] }

    no_results = File.read(Rails.root.to_s + "/spec/fixtures/json/google/web_search/no_results.json")
    stubs.get("#{common}#{common_params}&q=no_results") { [200, {}, no_results] }

    @test = Faraday.new do |builder|
      builder.adapter :test, stubs
      builder.response :rashify
      builder.response :json
    end
    Faraday.stub!(:new).and_return @test
  end

  it_behaves_like "a search engine"

  describe ".new for GoogleSearch" do
    context 'when only required search params are passed in' do
      let(:minimum_search) { GoogleSearch.new(query: "taxes") }
      it 'should set appropriate defaults' do
        minimum_search.query.should == 'taxes'
        minimum_search.offset.should == 1
        minimum_search.filter_level.should == 'medium'
        minimum_search.per_page.should == 10
      end
    end

    context 'when all search params are passed in' do
      let(:fully_specified_search) { GoogleSearch.new(query: "taxes", offset: 11, per_page: 8, filter: 2) }
      it 'should set appropriate values from params' do
        fully_specified_search.query.should == 'taxes'
        fully_specified_search.offset.should == 11
        fully_specified_search.filter_level.should == 'high'
        fully_specified_search.per_page.should == 8
      end
    end

    describe "adult content filters" do
      context "when a valid filter parameter is present" do
        it "should set the filter_level parameter to the Bing-specific level" do
          GoogleSearch.new(query: "taxes", filter: 0).filter_level.should == 'off'
          GoogleSearch.new(query: "taxes", filter: 1).filter_level.should == 'medium'
          GoogleSearch.new(query: "taxes", filter: 2).filter_level.should == 'high'
        end
      end

      context "when the filter parameter is blank/invalid" do
        it "should set the filter_level parameter to the default value (medium)" do
          GoogleSearch.new(query: "taxes", filter: '').filter_level.should == 'medium'
          GoogleSearch.new(query: "taxes", filter: 'whatevs').filter_level.should == 'medium'
        end
      end
    end
  end
end