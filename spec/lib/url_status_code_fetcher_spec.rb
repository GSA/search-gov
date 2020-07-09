require 'spec_helper'

describe UrlStatusCodeFetcher do
  # UrlStatusCodeFetcher uses Curl::Multi, which does not play nicely with either
  # Webmock or VCR. We might consider swapping out Curb in favor of Faraday, which
  # has more dev support, is more easily stubbed, and is already used extensively
  # in our code.

  let(:valid_url) { "https://search.gov/" }
  let(:invalid_url) { "https://www.google.com/404" }

  describe '.fetch' do
    context 'when block is given' do
      it 'fetches status code with a block' do
        responses = {}
        urls = [valid_url, invalid_url]

        UrlStatusCodeFetcher.fetch urls do |url, status|
          responses[url] = status.match(/\d+/).to_s
        end

        expect(responses).to eq({ valid_url => '200',
                              invalid_url => '404' })
      end
    end

    context 'when block is not given' do
      it 'fetches status code' do
        urls = [valid_url, invalid_url]

        responses = UrlStatusCodeFetcher.fetch urls
        expect(responses[valid_url]).to match(/200/)
        expect(responses[invalid_url]).to match(/404/)
      end
    end

    context 'when execution expired' do
      it 'logs Timeout::Error' do
        urls = %w(http://www.example.com/doc1 http://www.example.com/doc2)
        expect(Timeout).to receive(:timeout).with(30).and_raise Timeout::Error
        expect(Rails.logger).to receive(:warn)

        UrlStatusCodeFetcher.fetch urls
      end
    end
  end
end
