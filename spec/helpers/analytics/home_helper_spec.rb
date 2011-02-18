require "#{File.dirname(__FILE__)}/../../spec_helper"

describe Analytics::HomeHelper do
  describe "#analytics_center_breadcrumbs" do
    it "should render Analytics Center as the page title if page_title parameter is blank" do
      helper.should_receive(:breadcrumbs).with([link_to('Search.USA.gov', searchusagov_path), "Analytics Center"])
      helper.analytics_center_breadcrumbs
    end

    it "should render Analytics Center as link followed by page title if page_title parameter is not blank" do
      helper.should_receive(:default_url_options).and_return({:locale => I18n.locale, :m => "false"})
      helper.should_receive(:breadcrumbs).with([link_to('Search.USA.gov', searchusagov_path), link_to("Analytics Center", analytics_home_page_path), 'page_title'])
      helper.analytics_center_breadcrumbs('page_title')
    end
  end
end
