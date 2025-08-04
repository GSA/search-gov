require 'spec_helper'

describe DocumentFetcher do
  describe '.fetch' do
    context 'when the request is redirected' do
      let(:url) { 'http://healthcare.gov' }
      let(:new_url) { 'https://www.healthcare.gov/' }

      before do
        stub_request(:get, url).to_return(status: 301, headers: { location: new_url })
        stub_request(:get, new_url).to_return(status: 200, body: 'success')
      end

      it 'follows the redirect' do
        response = described_class.fetch url
        expect(response[:status]).to eq('200')
        expect(response[:last_effective_url]).to eq('https://www.healthcare.gov/')
        expect(response[:body]).to eq('success')
      end
    end

    context 'when there are too many redirects' do
      let(:url) { 'http://healthcare.gov' }
      let(:redirect_url) { 'http://redirect.gov' }

      before do
        stub_request(:get, url).to_return(status: 301, headers: { location: redirect_url })
        stub_request(:get, redirect_url).to_return(status: 301, headers: { location: redirect_url })
      end

      it 'returns an error' do
        result = described_class.fetch(url, limit: 1)
        expect(result[:error]).to eq('Too many redirects')
      end
    end

    context 'when a non-success HTTP status is returned' do
      let(:url) { 'http://healthcare.gov' }

      before do
        stub_request(:get, url).to_return(status: 500, message: 'Internal Server Error')
      end

      it 'returns the error message' do
        result = described_class.fetch(url)
        expect(result[:error]).to eq('500 Internal Server Error')
      end
    end

    context 'when a network error occurs' do
      let(:url) { 'http://healthcare.gov' }

      before do
        stub_request(:get, url).to_raise(Timeout::Error.new('execution expired'))
      end

      it 'returns the error message' do
        result = described_class.fetch(url)
        expect(result[:error]).to eq('execution expired')
      end
    end

    #sanity check, as a lot of tests rely on this working
    it 'can be stubbed by Webmock' do
      stub_request(:get,'https://www.healthcare.gov/').to_return({body: 'foo', status: 200})
      expect(described_class.fetch 'https://www.healthcare.gov/').
        to eq ({ body: 'foo',  last_effective_url: 'https://www.healthcare.gov/', status: '200' })
    end
  end
end
