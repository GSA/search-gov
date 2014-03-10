require 'spec_helper'

describe UrlStatusCodeFetcher do
  describe '.fetch' do
    context 'when block is given' do
      it 'fetches status code with a block' do
        responses = {}
        urls = %w(https://search.usa.gov/login http://search.digitalgov.gov/invalid-page)

        UrlStatusCodeFetcher.fetch urls do |url, status|
          responses[url] = status.match(/\d+/).to_s
        end

        responses.should == { 'https://search.usa.gov/login' => '200',
                              'http://search.digitalgov.gov/invalid-page' => '404' }
      end
    end

    context 'when block is not given' do
      it 'fetches status code' do
        urls = %w(https://search.usa.gov/login http://search.digitalgov.gov/invalid-page)

        responses = UrlStatusCodeFetcher.fetch urls
        responses['https://search.usa.gov/login'].should =~ /200/
        responses['http://search.digitalgov.gov/invalid-page'].should =~ /404/
      end
    end
  end
end
