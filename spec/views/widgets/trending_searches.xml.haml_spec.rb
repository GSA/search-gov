require 'spec/spec_helper'

describe "widgets/trending_searches.xml.haml" do
  let(:trending_search_without_url) { mock_model(TopSearch, { :query => 'hurricane', :url => nil, :position => 1 })}
  let(:trending_search_with_url) { mock_model(TopSearch, { :query => 'storm', :url => 'http://www.agency.gov/storm', :position => 2 }) }
  let(:active_top_searches) { [trending_search_without_url, trending_search_with_url] }

  before do
    assign(:active_top_searches, active_top_searches)
  end

  it "should have trending_searches" do
    render
    rendered.should have_selector(:"trending-searches") do |trending_searches|
      trending_searches.should have_selector(:"trending-search") do |trending_search|
        trending_search.should have_selector(:query, :content => 'hurricane')
        trending_search.should have_selector(:url, :content => 'http://test.host/search')
        trending_search.should have_selector(:query, :content => 'storm')
        trending_search.should have_selector(:url, :content => 'http://www.agency.gov/storm')
      end
    end
  end
end
