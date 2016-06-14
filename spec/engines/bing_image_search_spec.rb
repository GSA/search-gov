# coding: utf-8
require 'spec_helper'

describe BingImageSearch do

    let(:image_search) { BingImageSearch.new(query: "white house", enable_highlighting: true) }
    let(:search_response) { image_search.execute_query }


    it_should_behave_like "an image search"
end
