require 'spec_helper'

describe AttributeProcessor do

  describe '.prepend_attributes_with_http' do
    let(:record) { Affiliate.new(website: 'http://www.website.com', favicon_url: 'www.favicon.com') }
    it 'prefixes all URLs without http:// or https:// prefix' do
      described_class.prepend_attributes_with_http(record, :website, :favicon_url)
      expect([record.website, record.favicon_url]).to eq ['http://www.website.com', 'http://www.favicon.com']
    end
  end

  describe '.normalize_url' do
    it 'prefixes the url with http' do
      expect(described_class.normalize_url('www.foo.com')).to eq 'http://www.foo.com'
    end
  end
end
