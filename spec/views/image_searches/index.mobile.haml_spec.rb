# coding: utf-8
require 'spec_helper'

describe "image_searches/index.mobile.haml" do
  fixtures :affiliates, :image_search_labels, :navigations
  let(:affiliate) { affiliates(:usagov_affiliate) }

  context "when there are 5 Oasis pics and Bing image search is not enabled" do
    before do
      affiliate.is_bing_image_search_enabled = false
      assign(:affiliate, affiliate)
      results = (1..5).map do |i|
        Hashie::Mash::Rash.new(title: "title #{i}", url: "http://flickr/#{i}", display_url: "http://flickr/#{i}",
                         thumbnail: { url: "http://flickr/thumbnail/#{i}" })
      end
      results.stub(:total_pages).and_return(1)
      @search = double(ImageSearch, commercial_results?: false, query: "test", affiliate: affiliate, module_tag: 'OASIS',
                       queried_at_seconds: 1271978870, results: results, startrecord: 1, total: 5, per_page: 20,
                       page: 1, spelling_suggestion: nil)
      assign(:search, @search)
      assign(:search_params, { affiliate: affiliate.name, query: 'test' })
    end

    it "should show 5 Oasis pics" do
      selector = '#results .result.image'
      render
      rendered.should have_selector(selector, count: 5)
    end

    it "should be Powered by Search.gov" do
      render
      rendered.should contain("Powered by Search.gov")
    end
  end

  context "when there are 20 Oasis pics and Bing image search is enabled" do
    before do
      affiliate.is_bing_image_search_enabled = true
      assign(:affiliate, affiliate)
      results = (1..20).map do |i|
        Hashie::Mash::Rash.new(title: "title #{i}", url: "http://flickr/#{i}", display_url: "http://flickr/#{i}",
                         thumbnail: { url: "http://flickr/thumbnail/#{i}" })
      end
      results.stub(:total_pages).and_return(1)
      @search = double(ImageSearch, commercial_results?: false, query: "test", affiliate: affiliate, module_tag: 'OASIS',
                       queried_at_seconds: 1271978870, results: results, startrecord: 1, total: 20, per_page: 20,
                       page: 1, spelling_suggestion: nil)
      ImageSearch.stub(:===).and_return true
      assign(:search, @search)
      assign(:search_params, { affiliate: affiliate.name, query: 'test' })
    end

    it "should show 20 Oasis pics" do
      selector = '#results .result.image'
      render
      rendered.should have_selector(selector, count: 20)
    end

    it "should be Powered by Search.gov" do
      render
      rendered.should contain("Powered by Search.gov")
    end

    it "should have a link to retry search with Bing" do
      content = "Try your search again"
      render
      rendered.should have_selector(:a, content: content, href: '/search/images?affiliate=usagov&cr=true&query=test')
    end
  end

  context "when there are no Oasis pics and Bing image search is not enabled" do
    before do
      affiliate.is_bing_image_search_enabled = false
      assign(:affiliate, affiliate)
      @search = double(ImageSearch, query: "test", affiliate: affiliate, error_message: nil, module_tag: nil,
                       queried_at_seconds: 1271978870, results: [], startrecord: 0, total: 0, per_page: 20,
                       page: 0, spelling_suggestion: nil)
      assign(:search, @search)
      assign(:search_params, { affiliate: affiliate.name, query: 'test' })
    end

    it "should say no results found" do
      render
      rendered.should contain("no results found")
    end
  end

  context "when there are no Oasis results and Bing image search is enabled" do
    before do
      affiliate.is_bing_image_search_enabled = true
      assign(:affiliate, affiliate)
      results = (1..20).map do |i|
        Hashie::Mash::Rash.new(title: "title #{i}", url: "http://bing/#{i}", display_url: "http://bing/#{i}",
                         thumbnail: { url: "http://bing/thumbnail/#{i}" })
      end
      results.stub(:total_pages).and_return(1)
      @search = double(ImageSearch, commercial_results?: true, query: "test", affiliate: affiliate, module_tag: 'IMAG',
                       queried_at_seconds: 1271978870, results: results, startrecord: 1, total: 20, per_page: 20,
                       page: 1, spelling_suggestion: nil)
      ImageSearch.stub(:===).and_return true
      assign(:search, @search)
      assign(:search_params, { affiliate: affiliate.name, query: 'test' })
    end

    it "should show 20 Bing pics" do
      selector = '#results .result.image'
      render
      rendered.should have_selector(selector, count: 20)
    end

    it "should be Powered by Bing" do
      render
      rendered.should contain("Powered by Bing")
    end

  end

  describe "spelling suggestions" do
    context 'when it is from Oasis' do
      before do
        affiliate.is_bing_image_search_enabled = false
        assign(:affiliate, affiliate)
        results = (1..2).map do |i|
          Hashie::Mash::Rash.new(title: "title #{i}", url: "http://flickr/#{i}", display_url: "http://flickr/#{i}",
                           thumbnail: { url: "http://flickr/thumbnail/#{i}" })
        end
        results.stub(:total_pages).and_return(1)
        @search = double(ImageSearch, commercial_results?: false, query: "test", affiliate: affiliate, module_tag: 'OASIS',
                         queried_at_seconds: 1271978870, results: results, startrecord: 1, total: 2, per_page: 20,
                         page: 1, spelling_suggestion: "tsetse")
        assign(:search, @search)
        assign(:search_params, { affiliate: affiliate.name, query: 'test' })
        controller.stub(:controller_name).and_return('image_searches')
      end

      it "should have a link to redo search with Oasis spelling correction" do
        render
        rendered.should have_selector(:a, content: "tsetse", href: '/search/images?affiliate=usagov&query=tsetse')
      end
    end

    context 'when it is from Bing' do
      before do
        affiliate.is_bing_image_search_enabled = true
        assign(:affiliate, affiliate)
        results = (1..2).map do |i|
          Hashie::Mash::Rash.new(title: "title #{i}", url: "http://bing/#{i}", display_url: "http://bing/#{i}",
                           thumbnail: { url: "http://bing/thumbnail/#{i}" })
        end
        results.stub(:total_pages).and_return(1)
        @search = double(ImageSearch, commercial_results?: true, query: "test", affiliate: affiliate, module_tag: 'IMAG',
                         queried_at_seconds: 1271978870, results: results, startrecord: 1, total: 2, per_page: 20,
                         page: 1, spelling_suggestion: "\uE000tsetse\uE001")
        ImageSearch.stub(:===).and_return true
        assign(:search, @search)
        assign(:search_params, { affiliate: affiliate.name, query: 'test' })
        assign(:search_options, {})
        controller.stub(:controller_name).and_return('image_searches')
      end

      it "should have a link to redo search with Bing spelling correction" do
        render
        rendered.should have_selector(:a, content: "tsetse", href: '/search/images?affiliate=usagov&query=tsetse')
      end

    end
  end

end
