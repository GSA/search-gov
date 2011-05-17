require 'spec/spec_helper'

describe Analytics::HomeHelper do
  fixtures :affiliates

  describe "#analytics_center_breadcrumbs" do
    it "should render Analytics Center as the page title if page_title parameter is blank" do
      helper.should_receive(:breadcrumbs).with([link_to('Search.USA.gov', searchusagov_path), "Analytics Center"])
      helper.analytics_center_breadcrumbs
    end

    it "should render Analytics Center as link followed by page title if page_title parameter is not blank" do
      helper.should_receive(:breadcrumbs).with([link_to('Search.USA.gov', searchusagov_path), link_to("Analytics Center", analytics_home_page_path), 'page_title'])
      helper.analytics_center_breadcrumbs('page_title')
    end
  end

  describe "#query_chart_link" do
    it "should render query chart link" do
      content = helper.query_chart_link('query')
      content.should have_selector("a[href^='/analytics/timeline/query']", :content => "query")
      content.should have_selector("a[href^='/analytics/timeline/query'][title='Open graph in new window']")
    end
  end

  describe "#affiliate_query_chart_link" do
    it "should render query chart link" do
      content = helper.affiliate_query_chart_link('query', affiliates(:power_affiliate))
      content.should have_selector("a[href^='/affiliates/#{affiliates(:power_affiliate).id}/analytics/timeline/query']", :content => 'query')
      content.should have_selector("a[href^='/affiliates/#{affiliates(:power_affiliate).id}/analytics/timeline/query'][title='Open graph in new window']")
    end
  end
end
