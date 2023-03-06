require 'spec_helper'

describe UrlParser do
  describe '.normalize' do
    it 'should prefix URL without http:// or https:// prefix' do
      url = 'www.usa.gov'
      expect(described_class.normalize(url)).to eq('http://www.usa.gov/')
    end

    it 'should normalize URL' do
      url = 'https://www.USA.gov.//blog/..//NEWS releases?z=a;y=b&x=c'
      expect(described_class.normalize(url)).to eq('https://www.usa.gov/NEWS%20releases?z=a;y=b&x=c')
    end
  end

  describe '.mime_type' do
    it 'should identify images' do
      %w(gif JPEG png).each do |ext|
        url = "http://some.agency.gov/media.#{ext}"
        expect(described_class.mime_type(url)).to eq("image/#{ext.downcase}")
      end
    end
  end

  describe '.normalize_host' do
    [
      { url: 'http://test1.example.com/foo',      expected_host: 'test1.example.com' },
      { url: 'https://test2.example.com/bar/baz', expected_host: 'test2.example.com' },
      { url: 'test3.example.com/quux',            expected_host: nil },
      { url: 'test4.html',                        expected_host: nil },
      { url: nil,                                 expected_host: nil },
    ].each do |example|
      it "returns #{example[:expected_host]} when given #{example[:url]}" do
        expect(described_class.normalize_host(example[:url])).to eq(example[:expected_host])
      end
    end
  end

  describe '.update_scheme' do
    it 'updates the scheme' do
      expect(described_class.update_scheme('http://test.gov', 'https')).to eq 'https://test.gov'
    end
  end

  describe '.redact_query' do
    subject(:redact_query) { described_class.redact_query(url) }

    context 'without a query param' do
      let(:url) { 'https://foo.gov' }

      it { is_expected.to eq 'https://foo.gov' }
    end

    context 'when the URL includes a query param that may contain sensitive information' do
      let(:url) { 'https://foo.gov/search?query=123456789' }

      it 'redacts the potentially sensitive information' do
        expect(redact_query).to eq('https://foo.gov/search?query=REDACTED_SSN')
      end
    end

    context 'when the URL contains params that only resemble sensitive information' do
      let(:url) { 'https://foo.gov/search?utm_x=123456789' }

      it 'does not redact the non-sensitive params' do
        expect(redact_query).to match(/utm_x=123456789/)
      end
    end

    context 'when the URL is nil' do
      let(:url) { nil }

      it { is_expected.to be_nil }
    end
  end
end
