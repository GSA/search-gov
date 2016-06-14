require 'spec_helper'

describe AzureCompositeEngine do
  describe 'connection caching' do
    let(:azure_engine_unlimited_connection) { AzureEngine.unlimited_api_connection }
    let(:azure_engine_rate_limited_connection) { AzureEngine.rate_limited_api_connection }

    context 'when using unlimited API connections' do
      let(:connection_a) { described_class.unlimited_api_connection }
      let(:connection_b) { described_class.unlimited_api_connection }

      it 'should reuse the same connection' do
        expect(connection_a).to eq(connection_b)
      end

      it 'should not reuse the connection created by AzureEngine' do
        expect(connection_a.class).to eq(azure_engine_unlimited_connection.class)
        expect(connection_a).not_to eq(azure_engine_unlimited_connection)
      end
    end

    context 'when using rate-limited API connections' do
      let(:connection_a) { described_class.rate_limited_api_connection }
      let(:connection_b) { described_class.rate_limited_api_connection }

      it 'should be the same connection' do
        expect(connection_a).to eq(connection_b)
      end

      it 'should not reuse the connection created by AzureEngine' do
        expect(connection_a.class).to eq(azure_engine_rate_limited_connection.class)
        expect(connection_a).not_to eq(azure_engine_rate_limited_connection)
      end
    end

    context 'when using a mix of unlimited and rate-limited API connections' do
      let(:connection_a) { described_class.unlimited_api_connection }
      let(:connection_b) { described_class.rate_limited_api_connection }

      it 'should be different connections' do
        expect(connection_a).not_to eq(connection_b)
      end
    end
  end

  describe 'api namespacing' do
    it 'uses the AzureCompositeEngine namespace' do
      described_class.api_namespace.should eq(AzureCompositeEngine::NAMESPACE)
    end

    it 'has a different namespace than AzureEngine' do
      described_class.api_namespace.should_not eq(AzureEngine::NAMESPACE)
    end
  end

  describe '#execute_query' do
    let(:engine) do
      described_class.new api_key: '***REMOVED***',
                          language: 'en',
                          sources: sources,
                          image_filters: image_filters,
                          offset: offset,
                          limit: 5,
                          query: query
    end
    let(:sources) { 'web+spell' }
    let(:image_filters) { nil }
    let(:offset) { 0 }
    let(:query) { 'survy (site:www.census.gov)' }

    subject(:response) { engine.execute_query }

    context 'when no results are present' do
      let(:query) { 'unpossible (site:www.census.gov)' }

      it 'sets total and next_offset' do
        expect(response.total).to eq(0)
        expect(response.next_offset).to eq(nil)
      end
    end

    context 'when web results are present' do
      it 'sets total and next_offset' do
        expect(response.total).to be > 100
        expect(response.next_offset).to eq(5)
      end

      it 'sets spelling suggestion' do
        expect(response.spelling_suggestion).to eq('survey')
      end
    end

    context 'when no next page of results is available' do
      let(:offset) { 1000 }

      it 'sets total and next_offset' do
        expect(response.total).to be > 100
        expect(response.next_offset).to eq(nil)
      end
    end

    context 'when image results are present' do
      let(:sources) { 'image+spell' }
      let(:image_filters) { 'Aspect:Square' }
      let(:query) { 'white house' }

      it 'sets total and next_offset' do
        expect(response.total).to be > 100
        expect(response.next_offset).to eq(5)
      end
    end

    context 'when a spelling suggestion is available' do
      let(:query) { 'survy' }

      it 'sets spelling suggestion' do
        expect(response.spelling_suggestion).to eq('survey')
      end
    end
  end
end
