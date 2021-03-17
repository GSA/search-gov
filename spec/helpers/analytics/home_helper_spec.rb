require 'spec_helper'

describe Analytics::HomeHelper do
  fixtures :affiliates

  let(:affiliate) { affiliates(:basic_affiliate) }

  describe '#rtu_affiliate_analytics_monthly_report_link' do
    subject { helper.rtu_affiliate_analytics_monthly_report_link(affiliate, Date.parse('2014-06-09')) }

    it { is_expected.to be_html_safe }
    it { is_expected.to match('Download top queries for June 2014') }
    it { is_expected.to have_link('csv', href: "/sites/#{affiliate.id}/query_downloads.csv?end_date=2014-06-30&start_date=2014-06-01") }
  end

  describe '#query_drilldown_link(site, query, start_date, end_date)' do
    subject { helper.query_drilldown_link(affiliate, 'foo', Date.parse('2015-02-01'), Date.parse('2015-02-05')) }

    it { is_expected.to be_html_safe }
    it { is_expected.to have_link('Download Details', href: "/sites/#{affiliate.id}/query_drilldowns.csv?end_date=2015-02-05&query=foo&start_date=2015-02-01") }
  end

  describe '#click_drilldown_link(site, url, start_date, end_date)' do
    subject { helper.click_drilldown_link(affiliate, 'http://www.gov.gov/url.html', Date.parse('2015-02-01'), Date.parse('2015-02-05')) }

    it { is_expected.to be_html_safe }
    it { is_expected.to have_link('Download Details', href: "/sites/#{affiliate.id}/click_drilldowns.csv?end_date=2015-02-05&start_date=2015-02-01&url=http%3A%2F%2Fwww.gov.gov%2Furl.html") }
  end

  describe '#rtu_affiliate_analytics_weekly_report_links' do
    it 'should generate weekly links' do
      links = helper.rtu_affiliate_analytics_weekly_report_links(affiliate, Date.parse('2014-05-09'))
      expect(links.first).to be_html_safe
      expect(links.first).to match('Download top queries for the week of 2014-05-04')
      expect(links.first).to have_link('csv', href: "/sites/#{affiliate.id}/query_downloads.csv?end_date=2014-05-10&start_date=2014-05-04")
      expect(links.last).to be_html_safe
      expect(links.last).to match('Download top queries for the week of 2014-05-25')
      expect(links.last).to have_link('csv', href: "/sites/#{affiliate.id}/query_downloads.csv?end_date=2014-05-31&start_date=2014-05-25")
    end
  end

end
