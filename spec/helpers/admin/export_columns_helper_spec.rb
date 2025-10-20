# frozen_string_literal: true

require 'spec_helper'

describe Admin::ExportColumnsHelper do
  describe '#site_domains_export_column' do
    let(:helper) do
      Class.new do
        include Admin::ExportColumnsHelper
      end.new
    end

    let(:affiliate) { double('Affiliate', is_a?: true) }
    let(:site_domains) { double('SiteDomains') }

    before do
      allow(affiliate).to receive(:site_domains).and_return(site_domains)
      allow(site_domains).to receive(:pluck).with(:domain).and_return(['domain1.gov', 'domain2.gov', 'domain3.gov', 'domain4.gov', 'domain5.gov'])
    end

    it 'returns all domains joined with commas for Affiliate records' do
      result = helper.site_domains_export_column(affiliate)
      expect(result).to eq('domain1.gov,domain2.gov,domain3.gov,domain4.gov,domain5.gov')
    end

    it 'returns the site_domains association for non-Affiliate records' do
      non_affiliate = double('NonAffiliate', is_a?: false, site_domains: site_domains)
      result = helper.site_domains_export_column(non_affiliate)
      expect(result).to eq(site_domains)
    end
  end
end
