# coding: utf-8
require 'spec_helper'

describe GoogleWebSearch do

  it_behaves_like "a search engine"

  describe ".new for GoogleWebSearch" do
    context 'when only required search params are passed in' do
      let(:minimum_search) { GoogleWebSearch.new(query: "taxes") }
      it 'should set appropriate defaults' do
        minimum_search.query.should == 'taxes'
        minimum_search.filter_level.should == 'medium'
      end
    end

    context 'when all search params are passed in' do
      let(:fully_specified_search) { GoogleWebSearch.new(query: "taxes", offset: 11, filter: 2) }
      it 'should set appropriate values from params' do
        fully_specified_search.query.should == 'taxes'
        fully_specified_search.offset.should == 11
        fully_specified_search.filter_level.should == 'high'
      end
    end

    describe "adult content filters" do
      context "when a valid filter parameter is present" do
        it "should set the filter_level parameter to the Bing-specific level" do
          GoogleWebSearch.new(query: "taxes", filter: 0).filter_level.should == 'off'
          GoogleWebSearch.new(query: "taxes", filter: 1).filter_level.should == 'medium'
          GoogleWebSearch.new(query: "taxes", filter: 2).filter_level.should == 'high'
        end
      end

      context "when the filter parameter is blank/invalid" do
        it "should set the filter_level parameter to the default value (medium)" do
          GoogleWebSearch.new(query: "taxes", filter: '').filter_level.should == 'medium'
          GoogleWebSearch.new(query: "taxes", filter: 'whatevs').filter_level.should == 'medium'
        end
      end
    end
  end
end