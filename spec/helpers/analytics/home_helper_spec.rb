require 'spec_helper'

describe Analytics::HomeHelper do
  fixtures :affiliates

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
