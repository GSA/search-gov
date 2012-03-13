require 'spec/spec_helper'

describe Analytics::HomeHelper do
  fixtures :affiliates

  describe "#analytics_center_breadcrumbs" do
    it "should render Analytics Center as the page title if page_title parameter is blank" do
      helper.should_receive(:breadcrumbs).with(["Analytics Center"])
      helper.analytics_center_breadcrumbs
    end

    it "should render Analytics Center as link followed by page title if page_title parameter is not blank" do
      helper.should_receive(:breadcrumbs).with([link_to("Analytics Center", analytics_home_page_path), 'page_title'])
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

  describe "#affiliate_analytics_daily_report_link" do
    context "s3 file exists" do
      before do
        AWS::S3::S3Object.should_receive(:exists?).and_return(true)
        helper.should_receive(:daily_report_filename).and_return('my_super_report_filename')
        helper.should_receive(:s3_link).and_return("http://s3/my_super_report_filename")
        @content = helper.affiliate_analytics_daily_report_link('super site', Date.current)
      end

      subject { @content }
      it { should be_html_safe }

      it "should render the link" do
        @content.should have_selector("a[href='http://s3/my_super_report_filename']", :content => 'csv')
      end
    end
  end

  describe "#affiliate_analytics_monthly_report_link" do
    context "s3 file exists" do
      before do
        AWS::S3::S3Object.should_receive(:exists?).and_return(true)
        helper.should_receive(:monthly_report_filename).and_return('my_super_report_filename')
        helper.should_receive(:s3_link).and_return("http://s3/my_super_report_filename")
        @content = helper.affiliate_analytics_monthly_report_link('super site', Date.current)
      end

      subject { @content }
      it { should be_html_safe }

      it "should render the link" do
        @content.should have_selector("a[href='http://s3/my_super_report_filename']", :content => 'csv')
      end
    end
  end
end
