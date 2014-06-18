require 'spec_helper'

describe Analytics::HomeHelper do
  fixtures :affiliates

  let(:affiliate) { affiliates(:basic_affiliate) }

  describe "#rtu_affiliate_analytics_monthly_report_link" do
    subject { helper.rtu_affiliate_analytics_monthly_report_link(affiliate, Date.parse('2014-06-09')) }

    it { should be_html_safe }
    it { should match('Download top queries for June 2014') }
    it { should have_link('csv', href: "/sites/#{affiliate.id}/query_downloads.csv?end_date=2014-06-30&start_date=2014-06-01") }
  end

  describe "#rtu_affiliate_analytics_weekly_report_links" do
    it 'should generate weekly links' do
      links = helper.rtu_affiliate_analytics_weekly_report_links(affiliate, Date.parse('2014-05-09'))
      links.first.should be_html_safe
      links.first.should match('Download top queries for the week of 2014-05-04')
      links.first.should have_link('csv', href: "/sites/#{affiliate.id}/query_downloads.csv?end_date=2014-05-10&start_date=2014-05-04")
      links.last.should be_html_safe
      links.last.should match('Download top queries for the week of 2014-05-25')
      links.last.should have_link('csv', href: "/sites/#{affiliate.id}/query_downloads.csv?end_date=2014-05-31&start_date=2014-05-25")
    end

  end
end
