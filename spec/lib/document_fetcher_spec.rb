require 'spec_helper'

describe DocumentFetcher do
  describe '.fetch' do
    context 'when the request is redirected' do
      let(:url) { 'http://healthcare.gov' }
      let(:new_url) { 'https://www.healthcare.gov/' }

      before do
        stub_request(:get, url).to_return(status: 301, headers: { location: new_url })
        stub_request(:get, new_url).to_return(status: 200)
      end

      it 'follows the redirect' do
        response = described_class.fetch url
        expect(response[:status]).to match(/200/)
        expect(response[:last_effective_url]).to eq('https://www.healthcare.gov/')
      end
    end

    it 'returns empty hash when Curl::Easy raises error' do
      easy = double('easy')
      expect(Curl::Easy).to receive(:new).and_return(easy)
      expect(easy).to receive(:perform).and_raise(Curl::Err::TooManyRedirectsError)
      expect(described_class.fetch('http://healthcare.gov')).to eq(error: 'Curl::Err::TooManyRedirectsError')
    end

    it 'returns empty hash when the execution expired' do
      easy = double('easy')
      expect(Curl::Easy).to receive(:new).and_return(easy)
      expect(easy).to receive(:perform)

      response = described_class.fetch('http://healthcare.gov')
      expect(response[:error]).to match(/Unable to fetch/)
    end

    #sanity check, as a lot of tests rely on this working
    it 'can be stubbed by Webmock' do
      stub_request(:get,'https://www.healthcare.gov/').to_return({body: 'foo', status: 200})
      expect(described_class.fetch 'https://www.healthcare.gov/').
        to eq ({ body: 'foo',  last_effective_url: 'https://www.healthcare.gov/', status: '200' })
    end

    describe 'with timeout overrides' do
      let(:connection) { double(:connection,
                                'connect_timeout=': nil,
                                'follow_location=': nil,
                                'max_redirects=': nil,
                                'timeout=': nil,
                                'useragent=': nil,
                                'on_success': nil,
                                'on_redirect': nil) }
      let(:easy) { double(:easy, perform: nil) }

      before { allow(Curl::Easy).to receive(:new).and_yield(connection).and_return(easy) }

      context 'when given no timeout overrides' do
        it 'uses the default timeouts' do
          expect(connection).to receive(:'connect_timeout=').with(2)
          expect(connection).to receive(:'timeout=').with(8)
          described_class.fetch('http://healthcare.gov')
        end
      end

      context 'when given timeout overrides' do
        it 'uses the given timeout overrides' do
          expect(connection).to receive(:'connect_timeout=').with(42)
          expect(connection).to receive(:'timeout=').with(84)
          described_class.fetch('http://healthcare.gov', **{ connect_timeout: 42, read_timeout: 84 })
        end
      end
    end
  end
end
