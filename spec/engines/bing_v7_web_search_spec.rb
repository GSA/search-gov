# frozen_string_literal: true

describe BingV7WebSearch do
  subject(:search) { described_class.new(options) }

  it_behaves_like 'a Bing search'
  it_behaves_like 'a web search engine'

  it 'uses the correct host' do
    expect(described_class.api_host).to eq('https://api.bing.microsoft.com')
  end

  it 'uses the correct endpoint' do
    expect(described_class.api_endpoint).to eq('/v7.0/search')
  end

  describe '#hosted_subscription_key' do
    let(:options) { {} }

    before do
      ENV.fetch('BING_WEB_SUBSCRIPTION_ID') = 'web key'
    end

    it 'uses the web search key' do
      expect(search.hosted_subscription_key).to eq('web key')
    end
  end

  # SRCH-4311 Update:
  # This spec should be moved to shared bing_search_behavior, but we cannot do so until
  # we have clarity on the future of BingV7 Image search since we currently cannot run or
  # or record successful BingV7 image searches.
  context 'when a Spanish site runs a search that could return location results' do
    let(:params) do
      { query: 'hotel (site:search.gov)' }
    end

    before { allow(Language).to receive(:bing_market_for_code).and_return('es-US') }

    it 'returns no results' do
      expect(described_class.new(params).execute_query.total).to eq 0
    end
  end
end
