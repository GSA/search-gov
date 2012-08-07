require 'spec_helper'

describe "widgets/trending_searches.xml.haml" do
  fixtures :affiliates

  context "when no affiliate is present" do
    before do
      trending_search_without_url = mock_model(TopSearch, { :query => 'hurricane', :url => nil, :position => 1 })
      trending_search_without_url.stub!(:affiliate).and_return nil
      trending_search_with_url = mock_model(TopSearch, { :query => 'storm', :url => 'http://www.agency.gov/storm', :position => 2 })
      trending_search_with_url.stub!(:affiliate).and_return nil
      active_top_searches = [trending_search_without_url, trending_search_with_url]
      assign(:active_top_searches, active_top_searches)
      assign(:widget_source, 'agency')
    end

    it "should have trending_searches" do
      render
      rendered.should have_selector(:"trending-searches") do |trending_searches|
        trending_searches.should have_selector(:"trending-search") do |trending_search|
          trending_search.should have_selector(:query, :content => 'hurricane')
          trending_search.should have_selector(:url, :content => 'http://test.host/search?linked=1&position=1&query=hurricane&widget_source=agency')
          trending_search.should have_selector(:query, :content => 'storm')
          trending_search.should have_selector(:url, :content => 'http://www.agency.gov/storm')
        end
      end
    end
  end

  context "when there is an affiliate" do
    before do
      top_search = mock_model(TopSearch, { :query => 'storm', :url => nil, :position => 2, :affiliate_id => affiliates(:basic_affiliate).id })
      top_search.stub!(:affiliate).and_return affiliates(:basic_affiliate)
      active_top_searches = [top_search]
      assign(:active_top_searches, active_top_searches)
      assign(:widget_source, 'agency')
    end

    it "should have trending_searches with search urls linked to the affiliate serps" do
      render
      rendered.should have_selector(:"trending-searches") do |trending_searches|
        trending_searches.should have_selector(:"trending-search") do |trending_search|
          trending_search.should have_selector(:query, :content => 'storm')
          trending_search.should have_selector(:url, :content => "http://test.host/search?affiliate=#{affiliates(:basic_affiliate).name}&linked=1&position=2&query=storm&widget_source=agency")
        end
      end
    end
  end
end