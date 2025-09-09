require 'spec_helper'

describe UrlStatusCodeFetcher do
  let(:valid_url) { 'https://search.gov/' }
  let(:invalid_url) { 'https://www.google.com/404' }

  describe '.fetch' do
    context 'when block is given' do
      xit 'fetches status code with a block' do
        responses = {}
        urls = [valid_url, invalid_url]

        described_class.fetch urls do |url, status|
          responses[url] = status.match(/\d+/).to_s
        end

        expect(responses).to eq({ valid_url => '200',
                              invalid_url => '404' })
      end
    end

    context 'when block is not given' do
      xit 'fetches status code' do
        urls = [valid_url, invalid_url]

        responses = described_class.fetch urls
        expect(responses[valid_url]).to match(/200/)
        expect(responses[invalid_url]).to match(/404/)
      end
    end

    context 'when execution expired' do
      it 'logs Timeout::Error' do
        urls = %w(http://www.example.com/doc1 http://www.example.com/doc2)
        expect(Timeout).to receive(:timeout).with(30).and_raise Timeout::Error
        expect(Rails.logger).to receive(:warn)

        described_class.fetch urls
      end
    end
  end
end