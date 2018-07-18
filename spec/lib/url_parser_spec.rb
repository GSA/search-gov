require 'spec_helper'

describe UrlParser do
  describe '.normalize' do
    it 'should prefix URL without http:// or https:// prefix' do
      url = 'www.usa.gov'
      expect(UrlParser.normalize(url)).to eq('http://www.usa.gov/')
    end

    it 'should normalize URL' do
      url = 'https://www.USA.gov.//blog/..//NEWS releases?z=a;y=b&x=c'
      expect(UrlParser.normalize(url)).to eq('https://www.usa.gov/NEWS%20releases?z=a;y=b&x=c')
    end
  end

  describe '.mime_type' do
    it 'should identify images' do
      %w(gif JPEG png).each do |ext|
        url = "http://some.agency.gov/media.#{ext}"
        expect(UrlParser.mime_type(url)).to eq("image/#{ext.downcase}")
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
        expect(UrlParser.normalize_host(example[:url])).to eq(example[:expected_host])
      end
    end
  end

  describe '.update_scheme' do
    it 'updates the scheme' do
      expect(UrlParser.update_scheme('http://test.gov', 'https')).to eq 'https://test.gov'
    end
  end
end
